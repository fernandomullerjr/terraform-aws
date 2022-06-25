variable "aws_region" {
  description = "AWS region where the resources will be created"

  type = object({
    dev  = string
    prod = string
  })

  default = {
    dev  = "us-east-1"
    prod = "us-east-2"
  }
}

variable "instance" {
  description = "Instance configuration per workspace"

  type = object({
    dev = object({
      ami    = string
      type   = string
      number = number
    })
    prod = object({
      ami    = string
      type   = string
      number = number
    })
  })

  default = {
    dev = {
      ami    = "ami-08d4ac5b634553e16"
      type   = "t2.micro"
      number = 1
    }
    prod = {
      ami    = "ami-0960ab670c8bb45f3"
      type   = "t3.micro"
      number = 3
    }
  }
}
