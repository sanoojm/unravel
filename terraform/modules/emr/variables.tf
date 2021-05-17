variable "emr_version" {}
variable "key_pair" {}
variable "subnet_id" {}
variable "whitelist_sg" { default = { "inbound" : [] } }
variable "whitelist_self" { default = { "inbound" : [] } }
variable "tags" {}
variable "cidr_admin_whitelist" { default = [] }
variable "security_groups" { default = [] }

