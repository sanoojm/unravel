variable "region" {
  description = "Must be in the same region as the target EMR clusters, which the Unravel EC2 node will be monitoring."
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "Unravel server instance type"
  type        = string
  default     = "t2.xlarge"
}

variable "public_subnet_id" {
  description = "Subnet ID to deploy Unravel server"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID to deploy EMR Cluster"
  type        = string
}

variable "emr_security_group" {
  description = "Whitelist EMR security group"
  type        = string
}


variable "emr_version" {
  description = "Subnet ID to deploy Unravel server"
  type        = string
}

variable "create_vpc_endpoint_s3" {
  description = "Subnet ID to deploy Unravel server"
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "Valid AWS Key Pair"
  default     = ""
}

variable "public_key_path" {
  description = "My public ssh key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "custom_bootstraps" {
  description = "CIDR ranges permitted to communicate with administrative endpoints"
  type        = list(object({
    name = string,
    path = string,
    args = list(string)
  }
          ))
  default     = []
}

variable "cidr_admin_whitelist" {
  description = "CIDR ranges permitted to communicate with administrative endpoints"
  type        = list
  default     = []
}

variable "tags" {
  description = "Unravel Data Reosurce Tagging"
  type        = map
  default = {
    "Name" : "Unrvel Data Server"
    "app" : "Unravel"
    "env" : "production"
  }

}

