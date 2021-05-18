locals {
  unravel_bootstrap = [{
    "name" : "Unravel bootstrap",
    "path" : "${module.s3.bucket_name}/artifacts/unravel_emr_bootstrap.py"
    "args" : [
    "--unravel-server ${module.unravel_server.private_ip} --all --bootstrap"]
  }]
  aws_emr_service_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
}


# Creates instance profile for EMR server
module "emr_instance_profile" {
  source = "./modules/instance_profile"

  name        = "unravel_server"
  policy_path = "./files/emr/instance_policy.txt"
  role_path   = "./files/emr/instance_role.txt"

  tags = var.tags

}


# Creates Security Groups for EMR server.
module "emr_sg" {
  source = "./modules/sg"

  vpc_id  = data.aws_subnet.private_subnet.vpc_id
  sg_name = "EMR security Group"
  whitelist_self = {
    "inbound" : [
      {
        "protocol" : "tcp",
        "from_port" : "0",
        "to_port" : "0"
      },
      {
        "protocol" : "udp",
        "from_port" : "0",
        "to_port" : "0"
      },
      {
        "protocol" : "ICMP",
        "from_port" : "0",
        "to_port" : "0"
      }
    ],
  }
  whitelist = {
    "inbound" : [],
    "outbound" : [
      {
        "protocol" : "-1"
        "from_port" : "0"
        "to_port" : "0"
        "cidr_blocks" : [
        "0.0.0.0/0"]
      }
    ]
  }
  tags = var.tags
}


# Creates S3 bucket to store Bootstrap Artifacts
module "s3" {
  source = "./modules/s3"

  bucket_name = "unravel-bootstrap-${data.aws_caller_identity.current.account_id}-${var.region}"
  directories = [
    "artifacts/",
  "logs/"]

  tags = var.tags
}


data "http" "unravel_bootstrap" {
  url = "https://s3.amazonaws.com/unraveldatarepo/unravel_emr_bootstrap.py"
}


# Uploads the files and contents to S3 location
module "bootstrap_s3_uploads" {
  source = "./modules/s3_uploads"

  content_uploads = true
  bucket_name     = module.s3.bucket_name
  content = {
    "artifacts/unravel_emr_bootstrap.py" : data.http.unravel_bootstrap.body
  }

  tags = var.tags
}


# https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html
# Create VPC endpoint between EMR and S3
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  count        = var.create_vpc_endpoint_s3 ? 0 : 0
  vpc_id       = data.aws_subnet.private_subnet.vpc_id
  service_name = format("com.amazonaws.%s.s3", var.region)
  auto_accept  = true
  route_table_ids = [
  data.aws_route_table.route.route_table_id]

  tags = var.tags

}

# Creates an IAM role for instance profile
resource "aws_iam_role" "service_role" {

  name                  = "emr_service_role"
  assume_role_policy    = file("./files/emr/service_role.txt")
  force_detach_policies = true

  tags = merge(var.tags)
}

resource "aws_iam_policy_attachment" "emr_policy_attach" {
  name       = "emr_policy_attachment"
  roles      = [aws_iam_role.service_role.name]
  policy_arn = local.aws_emr_service_policy_arn
}

module "emr" {
  source = "./modules/emr"

  emr_version          = ""
  key_name             = var.key_pair_name == "" ? aws_key_pair.keypair[0].key_name : var.key_pair_name
  subnet_id            = var.private_subnet_id
  security_group_id    = module.emr_sg.sg_id
  bootstrap            = concat(var.custom_bootstraps, local.unravel_bootstrap)
  emr_profile_arn      = module.emr_instance_profile.instance_profile_arn
  emr_service_role_arn = aws_iam_role.service_role.arn

  tags = var.tags

}