

# Aula 19. Data sources

Dia 02/04/2022

- Data Source em inglês é fonte de dados.
- No Terraform os Data Source permitem a busca de dados de outros projetos do Terraform ou até mesmo fora do Terraform.

- Acessando a página do S3 na documentação do Terraform, temos os Resources e os Data Sources, ao filtrar por "S3" na esquerda.
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket>

- No S3 conseguimos usar os seguintes Data Sources:
    aws_canonical_user_id
    aws_s3_bucket
    aws_s3_bucket_object
    aws_s3_bucket_objects
    aws_s3_object
    aws_s3_objects


- Exemplo de uma configuração do Route53, onde ele obtem dados de um Bucket pré-existente:

~~~hcl
data "aws_s3_bucket" "selected" {
  bucket = "bucket.test.com"
}

data "aws_route53_zone" "test_zone" {
  name = "test.com."
}

resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.test_zone.id
  name    = "bucket"
  type    = "A"

  alias {
    name    = data.aws_s3_bucket.selected.website_domain
    zone_id = data.aws_s3_bucket.selected.hosted_zone_id
  }
}
~~~



# Data Source - AMI

<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami>




data.tf

data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "ubuntu"
}



ec2.tf

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}



main.tf

terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-968339500772"
    key     = "dev/03-data-sources-s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "fernandomuller"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}