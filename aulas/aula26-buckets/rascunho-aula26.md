
# Aula 26 - Buckets

# TERRAFORM
- Criada estrutura na pasta terraform.

- Ajustando as variáveis:

~~~~h
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

variable "domain" {
  type        = string
  description = ""
  default     = ""
}
~~~~



- Ajustando a versão no main.tf:

~~~~h
terraform {
  required_version = "1.1.5"
~~~~



- Ajustando arquivo backend.hcl

de:

~~~~h
bucket         = "tfstate-968339500772"
key            = "03-static-website/terraform.tfstate"
region         = "eu-central-1"
profile        = "tf014"
dynamodb_table = "tflock-tfstate-968339500772"
~~~~

para:

~~~~h
bucket         = "tfstate-261106957109"
key            = "03-static-website/terraform.tfstate"
region         = "us-east-1"
profile        = "fernandomuller"
dynamodb_table = "tflock-tfstate-261106957109"
~~~~




- No nosso arquivo locals, temos algumas tags comum aos buckets que vamos criar:

~~~~h
  common_tags = {
    Project   = "Curso AWS com Terraform"
    Service   = "Static Website"
    CreatedAt = "2022-07-23"
    Module    = "3"
  }
~~~~


- Temos 2 locals que tratam sobre os dominios.
- Inicialmente vamos setar o dominio de forma aleatória usando o "random_pet", isto vai servir para que as pessoas que não tenham um dominio personalizado, consigam criar um website sem problemas.
- Posteriormente, vamos setar o dominio usando os locals.

~~~~h
  has_domain       = var.domain != ""
  domain           = local.has_domain ? var.domain : random_pet.website.id
~~~~



- No nosso arquivo s3.tf, vamos definir a policy de uma maneira diferente.
- Vamos apontar para uma policy em JSON num arquivo.
- Nas outras aulas vimos que a Policy era criada no manifesto do Terraform, no corpo mesmo.

- ANTES:

~~~~h
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${random_pet.website.id}/*"
            ]
        }
    ]
}
EOT
}
~~~~


- AGORA:

~~~~h
template = file("policy.json")
~~~~



- Arquivo JSON com a policy:

~~~~json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${cdn_oai}"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    }
  ]
}
~~~~





- Dentro do arquivo s3.tf:

~~~~h
data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars = {
    bucket_name = local.domain
    cdn_oai     = aws_cloudfront_origin_access_identity.this.id
  }
}
~~~~


- Observação.
- Este [bucket_name] no arquivo s3.tf é representado pelo [bucket_name] no arquivo policy.json.



- Como serão criados vários buckets, será utilizado um módulo do Cleber.
- URL do módulo:
<github.com/chgasparoto/terraform-s3-object-notification>
- Teremos 1 bucket para logs, 1 para website, e assim por diante.



3:57
3:57
3:57



dominio normal:
var.domain

endpoint para o bucket/ dominio do bucket:
module.website.website


# REVISAR
- Trello
3:57
3:57
3:57