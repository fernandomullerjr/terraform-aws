
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





# ############################################################################################################################################################
# ############################################################################################################################################################
# ############################################################################################################################################################
# ############################################################################################################################################################
# Dia 27/07/2022

- Continuando.
- Rodando o terraform init na pasta do projeto
terraform init

- Pediu algumas informações do S3:


- Deletando alguns arquivos do projeto.

- Removendo do main.tf

~~~~h
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  alias   = "us-east-1"
}
~~~~

- Ajustando o locals.tf
- Removendo 2 códigos
- Novo locals.tf:

~~~~h
locals {
  has_domain       = var.domain != ""
  domain           = local.has_domain ? var.domain : random_pet.website.id

  common_tags = {
    Project   = "Curso AWS com Terraform"
    Service   = "Static Website"
    CreatedAt = "2022-07-23"
    Module    = "3"
  }
}
~~~~



- No repositório o JSON da policy é esse:

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

- No video aos 3:11 é usada uma policy com asterisco no principal AWS:

~~~~json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    }
  ]
}
~~~~


- Usando a policy desta maneira acima, usando asterisco.


- No arquivo s3.tf, criado o bloco de data para o Template file.
- Usado um código baseado no video, porque o código do repositório tem informações a mais sobre "cdn_oai", "cloudfront", etc.
- Versão baseada no video aos 3:38:

~~~~h
data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars = {
    bucket_name = local.domain
  }
}
~~~~



- Criando os blocos sobre os módulos.
- Criando o módulo para os logs usando o source do Github do Cleber.
- Replicando para os demais módulos o mesmo trecho:

~~~~h
module "logs" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
}

module "website" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
}

module "redirect" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
}
~~~~



- Seguiu pedindo o backend S3, porém o bucket não está pré-criado, devido ser nova conta, etc.
- Comentado o backend S3.


- Criando um bucket via Terraform e também a tabela no DynamoDB, para a nova conta na AWS:
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3-NEW-nova-conta-aws/00-remote-state-bucket

~~~~bash
aws_s3_bucket.remote-state: Creating...
aws_s3_bucket.remote-state: Still creating... [10s elapsed]
aws_s3_bucket.remote-state: Creation complete after 12s [id=tfstate-261106957109]
aws_dynamodb_table.lock-table: Creating...
aws_dynamodb_table.lock-table: Creation complete after 10s [id=tflock-tfstate-261106957109]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

remote_state_bucket = "tfstate-261106957109"
remote_state_bucket_arn = "arn:aws:s3:::tfstate-261106957109"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3-NEW-nova-conta-aws/00-remote-state-bucket$
~~~~



- Usuário IAM
fernandomullerjr8596
- Profile da AWS nas credentials
fernandomullerjr8596


- Seguiu pedindo as informações do backend no S3:

Initializing the backend...
bucket
  The name of the S3 bucket

  Enter a value: ^C



- Resolvido.
- Foi necessário usar o comando abaixo, informando o caminho do arquivo hcl com as configurações do Backend:
terraform init -backend-config=backend.hcl

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ terraform init -backend-config=backend.hcl
Initializing modules...
Downloading git::https://github.com/chgasparoto/terraform-s3-object-notification.git for logs...
- logs in .terraform/modules/logs
- logs.notification in .terraform/modules/logs/modules/notification
- logs.objects in .terraform/modules/logs/modules/object
Downloading git::https://github.com/chgasparoto/terraform-s3-object-notification.git for redirect...
- redirect in .terraform/modules/redirect
- redirect.notification in .terraform/modules/redirect/modules/notification
- redirect.objects in .terraform/modules/redirect/modules/object
Downloading git::https://github.com/chgasparoto/terraform-s3-object-notification.git for website...
- website in .terraform/modules/website
- website.notification in .terraform/modules/website/modules/notification
- website.objects in .terraform/modules/website/modules/object

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/random versions matching "3.1.0"...
- Finding hashicorp/template versions matching "2.2.0"...
- Finding hashicorp/aws versions matching "3.32.0"...
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing hashicorp/aws v3.32.0...
- Installed hashicorp/aws v3.32.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$
~~~~


- Desta maneira, baixou os plugins corretamente.
- Iniciou todos os módulos corretamente.


- A opção "force_destroy" vai permitir que a gente possa deletar o bucket mesmo que ele tenha arquivos nele.
- Neste caso, devido o sinal de exclamação, o bucket só vai ser deletado quando não tiver o dominio setado.
  force_destroy = !local.has_domain


- Mais informações na documentação:
force_destroy - (Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable.


- Explicando no detalhe.
- No módulo "redirect", o website vai fazer o redirect para o dominio se a local dominio estiver definida, senão, vai usar o valor do id do bucket Website.
website = {
    redirect_all_requests_to = local.has_domain ? var.domain : module.website.website
  }
}



- Na configuração do s3.tf no video, tá diferente do repositório o filepath usado no módulo Website.
- No repositório está assim:
filepath = "${local.website_filepath}/build"
- No video está assim:
filepath = "${path.module}/../website/build"


- Ajustado o s3.tf
- Versão atual:

~~~~h
data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars = {
    bucket_name = local.domain
  }
}

module "logs" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
  name          = "${local.domain}-logs"
  acl           = "log-delivery-write"
  force_destroy = !local.has_domain
}

module "website" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
  name          = local.domain
  acl           = "public-read"
  policy        = data.template_file.s3-public-policy.rendered
  force_destroy = !local.has_domain

  versioning = {
    enabled = true
  }

#  filepath = "${local.website_filepath}/build"
  filepath = "${path.module}/../website/build"

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  logging = {
    target_bucket = module.logs.name
    target_prefix = "access/"
  }
}

module "redirect" {
  source        = "github.com/chgasparoto/terraform-s3-object-notification"
  name          = "www.${local.domain}"
  acl           = "public-read"
  force_destroy = !local.has_domain

  website = {
    redirect_all_requests_to = local.has_domain ? var.domain : module.website.website
  }
}

~~~~




- Criar o arquivo com as outputs.
outputs.tf
~~~~h
output "website-url" {
  value = local.has_domain ? var.domain : module.website.website
}
~~~~



- Efetuando o fmt, validate e o plan:
terraform fmt -recursive
terraform validate
terraform plan

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ terraform fmt -recursive
locals.tf
s3.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ terraform plan
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.template_file.s3-public-policy will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "s3-public-policy"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:GetObject"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "arn:aws:s3:::${bucket_name}/*"
                      + Sid       = "PublicReadForGetBucketObjects"
                    },
                ]
              + Version   = "2008-10-17"
            }
        )
      + vars     = {
          + "bucket_name" = (known after apply)
        }
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.logs.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "log-delivery-write"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # module.redirect.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + redirect_all_requests_to = (known after apply)
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + logging {
          + target_bucket = (known after apply)
          + target_prefix = "access/"
        }

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }

      + website {
          + error_document = "index.html"
          + index_document = "index.html"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + website-url = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$
~~~~





- Na saída do terraform plan, na parte do módulo Website, não existem os detalhes sobre os arquivos do nosso site.
- Indica que tem apenas 4 recursos para add.
- Faltava rodar o "npm run build".
- Subindo uma pasta acima e acessando a pasta "website", rodando o npm run build, para gerar o build do Node:
cd ../website/
npm run build

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ cd ../website/
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$ ls
node_modules  package.json  package-lock.json  public  README.md  src
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$ npm run build

> website@0.1.0 build
> react-scripts build

Creating an optimized production build...
Compiled successfully.

File sizes after gzip:

  46.64 kB  build/static/js/main.d58be654.js
  1.78 kB   build/static/js/787.71e672d5.chunk.js
  541 B     build/static/css/main.073c9b0a.css

The project was built assuming it is hosted at /.
You can control this with the homepage field in your package.json.

The build folder is ready to be deployed.
You may serve it with a static server:

  npm install -g serve
  serve -s build

Find out more about deployment here:

  https://cra.link/deployment

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$


Criada a pasta "build"

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$ ls
build  node_modules  package.json  package-lock.json  public  README.md  src
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$
~~~~








- Agora vem diversos recursos para add:
terraform plan

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/website$ cd ../terraform/
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ terraform plan
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.template_file.s3-public-policy will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "s3-public-policy"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:GetObject"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "arn:aws:s3:::${bucket_name}/*"
                      + Sid       = "PublicReadForGetBucketObjects"
                    },
                ]
              + Version   = "2008-10-17"
            }
        )
      + vars     = {
          + "bucket_name" = (known after apply)
        }
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.logs.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "log-delivery-write"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # module.redirect.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + redirect_all_requests_to = (known after apply)
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + logging {
          + target_bucket = (known after apply)
          + target_prefix = "access/"
        }

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }

      + website {
          + error_document = "index.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/json"
      + etag                   = "2b99189cbc4ddac9cf486ecf59af88a2"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "asset-manifest.json"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/asset-manifest.json"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "image/vnd.microsoft.icon"
      + etag                   = "c92b85a5b907c70211f4ec25e29a8c4a"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "favicon.ico"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/favicon.ico"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["index.html"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "388ccaafb727af791d148ac46cd3d3f2"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo192.png"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "image/png"
      + etag                   = "33dbdd0177549353eeeb785d02c294af"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "logo192.png"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/logo192.png"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo512.png"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "image/png"
      + etag                   = "917515db74ea8d1aee6a246cfbcc0b45"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "logo512.png"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/logo512.png"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["manifest.json"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/json"
      + etag                   = "d9d975cebe2ec20b6c652e1e4c12ccf0"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "manifest.json"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/manifest.json"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["robots.txt"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/plain; charset=utf-8"
      + etag                   = "fa1ded1ed7c11438a9b0385b1e112850"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "robots.txt"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/robots.txt"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/css; charset=utf-8"
      + etag                   = "89d76f95e100fc61f7271096ce86e7fc"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/css/main.073c9b0a.css"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/css/main.073c9b0a.css"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/octet-stream"
      + etag                   = "4284557f70f03d562b659f38b01eaa66"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/css/main.073c9b0a.css.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/css/main.073c9b0a.css.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/javascript"
      + etag                   = "d95602c8a8bdb73b00fa5ed23e902214"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/787.71e672d5.chunk.js"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/787.71e672d5.chunk.js"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/octet-stream"
      + etag                   = "048016cad13a1f842866ac9155dd2634"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/787.71e672d5.chunk.js.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/787.71e672d5.chunk.js.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/javascript"
      + etag                   = "5a6237f2967ef1def14f8451aa8e3182"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/plain; charset=utf-8"
      + etag                   = "b114cc85da504a772f040e3f40f8e46a"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js.LICENSE.txt"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js.LICENSE.txt"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/octet-stream"
      + etag                   = "fd1ad26d4746a2fbfed2145835fb7ddf"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "image/svg+xml"
      + etag                   = "06e733283fa43d1dd57738cfc409adbd"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + website-url = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$
~~~~



# PENDENTE
- Antes de fazer o apply, efetuar "npm run build" no projeto.
- Seguir com o apply.
- Destroy dos recursos depois.
- Ver sobre os states no backend S3, tabela do DynamoDB, 