variable "environment" {
  type        = string
  description = ""
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "instance_ami" {
  type        = string
  description = "Ubuntu 20 - ami"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags"
  default = {
    Name    = "Ubuntu"
    Project = "Curso AWS com Terraform"
  }
}