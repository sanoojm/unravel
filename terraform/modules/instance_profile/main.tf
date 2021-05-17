# Creates an instance profile for the server
resource "aws_iam_instance_profile" "instance_profile" {


  name = "${var.name}_instance_profile"
  role = aws_iam_role.iam_for_instance.name
}

# Creates an IAM role for instance profile
resource "aws_iam_role" "iam_for_instance" {

  name = "${var.name}_instance_role"
  assume_role_policy = file(var.role_path)
  force_detach_policies = true

  tags = merge(var.tags)
}

# Creates an IAM policy for instance profile
resource "aws_iam_role_policy" "instance_policy" {


  name = "${var.name}_instance_policy"
  role = aws_iam_role.iam_for_instance.id
  policy = file(var.policy_path)

}

