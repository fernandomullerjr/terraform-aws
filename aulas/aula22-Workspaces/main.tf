terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-816678621138"
    key            = "05-workspaces/terraform.tfstate"
    region         = "us-east-1"
    profile        = "fernandomuller"
    dynamodb_table = "tflock-tfstate-816678621138"
  }
}

provider "aws" {
  region  = lookup(var.aws_region, local.env)
  profile = "fernandomuller"
}

locals {
  env = terraform.workspace == "default" ? "dev" : terraform.workspace
}

resource "aws_instance" "web" {
  count = lookup(var.instance, local.env)["number"]

  ami           = lookup(var.instance, local.env)["ami"]
  instance_type = lookup(var.instance, local.env)["type"]

  tags = {
    Name = "Minha máquina web ${local.env}"
    Env  = local.env
  }
}
