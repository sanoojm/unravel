# Fetch the latest CentOS image from CentOS official Account
# https://wiki.centos.org/Cloud/AWS

data "aws_ami" "centos" {
  most_recent = true

  # CentOS official distribution
  owners = ["125523088429"]

  filter {
    name   = "name"
    values = ["CentOS 7.9.2009 x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }


}

# Get the subnet details including VPC id.
data "aws_subnet" "subnet" {
  id = var.public_subnet_id
}

# Create user data file using templates.
data "template_file" "unravel_user_data" {

  template = file("./templates/ec2/userdata.sh")

  vars = {
    version="4.7.0"
    url_version = "4.7.0.0"
    username = "admin"
    password = "unraveldata"
    region = var.region
  }
}

data "aws_route_table" "route" {
  subnet_id = var.public_subnet_id
}