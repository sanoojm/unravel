# Specify the provider and access details
provider "aws" {
  region = var.region
  # region = "us-west-2"
  version = "~> 2.0"
}


