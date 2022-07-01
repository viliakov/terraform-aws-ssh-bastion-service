
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}
