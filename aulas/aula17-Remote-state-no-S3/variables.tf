variable "aws_region" {
  type        = string
  description = ""
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = ""
  default     = "fernandomuller"
}

variable "ami" {
  type        = string
  description = ""
  default     = "ami-04505e74c0741db8d"
}

variable "instance_type" {
  type        = string
  description = ""
  default     = "t2.micro"
}