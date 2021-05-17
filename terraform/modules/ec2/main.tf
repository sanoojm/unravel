locals {
  common_tags = {
    Name = var.server_name
  }
}

# Get the subnet details including VPC id.
data "aws_subnet" "instance_subnet" {
  id    = var.subnet_id
}

# Creates a Bastion/Jump EC2 instance
resource "aws_instance" "ud_server" {


  ami                    = var.ami_id
  availability_zone      = data.aws_subnet.instance_subnet.availability_zone
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_pair
  vpc_security_group_ids = var.sg_ids
  iam_instance_profile   = var.instance_profile_name

  user_data_base64 = base64gzip(var.user_data)

  ebs_block_device {
    volume_type = "gp2"
    volume_size = 100
    device_name = var.device_mount_path

  }
  tags = merge(local.common_tags, var.tags)
}

# Creates a Elastic IP address
resource "aws_eip" "eip" {
  vpc  = true
  tags = merge(local.common_tags, var.tags)
}

# Associates the Elastic IP address to the Prometheus instance
resource "aws_eip_association" "eip_assoc" {

  instance_id   = aws_instance.ud_server.id
  allocation_id = aws_eip.eip.id

}
