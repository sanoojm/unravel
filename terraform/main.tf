
## Unravel server provisioning ##
# Uploads a new keypair
resource "aws_key_pair" "keypair" {
  count = var.key_pair_name == "" ? 1 : 0

  key_name   = "unravel-deployer-key"
  public_key = file(var.public_key_path)
}


# Creates Security Groups for Unravel server.
module "unravel_sg" {
  source = "./modules/sg"

  vpc_id  = data.aws_subnet.private_subnet.vpc_id
  sg_name = "Unravel server security Group"
  whitelist = {
    "inbound" : [
      {
        "protocol" : "tcp",
        "from_port" : "22",
        "to_port" : "22",
        "cidr_blocks" : var.cidr_admin_whitelist
      }
    ],
    "outbound" : [
      {
        "protocol" : "-1"
        "from_port" : "0"
        "to_port" : "0"
        "cidr_blocks" : ["0.0.0.0/0"]
      }
    ]

  }
  whitelist_sg = {
    "inbound" : [
      {
        "protocol" : "tcp",
        "from_port" : "3000",
        "to_port" : "3000",
        "security_groups" : var.emr_security_group
      },
      {
        "protocol" : "tcp",
        "from_port" : "4043",
        "to_port" : "4043",
        "security_groups" : var.emr_security_group
      }
    ]
  }
  whitelist_self = {
    "inbound" : [
      {
        "protocol" : "-1",
        "from_port" : "0",
        "to_port" : "0"
      }
    ]
  }

  tags = var.tags
}

# Creates instance profile for Unravel server
module "ec2_instance_profile" {
  source = "./modules/instance_profile"

  name        = "unravel_server"
  policy_path = "./files/ec2/instance_policy.txt"
  role_path   = "./files/ec2/instance_role.txt"

  tags = var.tags

}

# Provisions the EC2 instances as Unravel Server
module "unravel_server" {
  source = "./modules/ec2"

  region                = var.region
  server_name           = "unravel-server"
  instance_type         = var.instance_type
  subnet_id             = var.public_subnet_id
  vpc_id                = data.aws_subnet.public_subnet.vpc_id
  instance_profile_name = module.ec2_instance_profile.instance_profile_name

  ami_id   = data.aws_ami.centos.id
  key_pair_name = var.key_pair_name == "" && length(aws_key_pair.keypair) > 0 ? aws_key_pair.keypair[0].key_name : var.key_pair_name
  sg_ids   = [module.unravel_sg.sg_id]

  user_data = data.template_file.unravel_user_data.rendered


  ebs = false

  tags = var.tags
}
