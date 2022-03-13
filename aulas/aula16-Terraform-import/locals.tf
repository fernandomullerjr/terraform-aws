locals {

  ip_filepath = "ips.json"
  common_tags = {
    Name        = "Meu Super Bucket"
    Environment = var.environment
    Managedby   = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt   = "06-02-2022"
    Project     = "Curso do Cleber"
  }
}