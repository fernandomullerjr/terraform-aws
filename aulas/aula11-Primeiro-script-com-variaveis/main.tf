terraform {
  required_version = "1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket-teste" {
  bucket = "meu-bucket-de-teste-via-terraform--novo-02-03-2022"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby   = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt   = "03-02-2022"
    Project     = "Curso do Cleber"
  }
}

resource "aws_s3_bucket_acl" "acl-de-exemplo" {
  bucket = aws_s3_bucket.bucket-teste.id
  acl    = "private"
}