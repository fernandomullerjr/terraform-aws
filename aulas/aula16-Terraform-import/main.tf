terraform {
  required_version = "1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}