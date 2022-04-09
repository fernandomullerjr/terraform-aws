
# Aula 21. Modules

- Criando arquivos da aula, com base no repositório:
<https://github.com/chgasparoto/curso-aws-com-terraform/tree/master/02-terraform-intermediario/05-modules>

- Para declarar um módulo, chamamos o "module" e definimos um nome para ele(bucket), isso no main.tf principal da raíz.
- Também definimos o nome do Bucket com o campo "name", pois o campo name não tem um valor default no variables.tf do módulo s3_module.
- Trecho do arquivo main.tf da raíz do projeto:

~~~hcl
module "bucket" {
  source = "./s3_module"
  name   = random_pet.this.id

  versioning = {
    enabled = true
  }
}
~~~

- Arquivo variables.tf não tem um valor default para o "name", por isso precisamos definir um valor via random_pet anteriormente:

~~~hcl
variable "name" {
  type        = string
  description = "Bucket name"
}

variable "acl" {
  type        = string
  description = ""
  default     = "private"
}

variable "policy" {
  type        = string
  description = ""
  default     = null
}
~~~



- Rodando o terraform init, para iniciar o projeto.
terraform init

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform init
Initializing modules...
- bucket in s3_module
- bucket.objects in s3_module/s3_object
- website in s3_module
- website.objects in s3_module/s3_object

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.23.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/aws v3.23.0...
- Installed hashicorp/aws v3.23.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.2...
- Installed hashicorp/random v3.1.2 (signed by HashiCorp)

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~


- Após executar o terraform init, ele cria uma pasta oculta chamada ".terraform", dentro dela temos a pasta "modules".
- No arquivo "modules.json" temos o mapeamento de módulos no projeto.

~~~json
{
    "Modules": [
        {
            "Key": "",
            "Source": "",
            "Dir": "."
        },
        {
            "Key": "bucket",
            "Source": "./s3_module",
            "Dir": "s3_module"
        },
        {
            "Key": "bucket.objects",
            "Source": "./s3_object",
            "Dir": "s3_module/s3_object"
        },
        {
            "Key": "website",
            "Source": "./s3_module",
            "Dir": "s3_module"
        },
        {
            "Key": "website.objects",
            "Source": "./s3_object",
            "Dir": "s3_module/s3_object"
        }
    ]
}
~~~



- Efetuar o terraform plan para verificar o que vai ser criado:
terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.bucket.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
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
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects["error.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "a079b6818095cae21bf0d42a9369c0a6"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/error.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/error.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects["index.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "52d363c05c4a68ceaa5a3d934a89be97"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn           = (known after apply)
  + bucket-name          = (known after apply)
  + bucket-website-arn   = (known after apply)
  + bucket-website-files = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name  = (known after apply)
  + bucket-website-url   = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~




- Efetuar o apply
terraform apply -auto-approve

~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.bucket.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
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
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects["error.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "a079b6818095cae21bf0d42a9369c0a6"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/error.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/error.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects["index.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "52d363c05c4a68ceaa5a3d934a89be97"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn           = (known after apply)
  + bucket-name          = (known after apply)
  + bucket-website-arn   = (known after apply)
  + bucket-website-files = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name  = (known after apply)
  + bucket-website-url   = (known after apply)
random_pet.website: Creating...
random_pet.this: Creating...
random_pet.this: Creation complete after 0s [id=hugely-solely-eagerly-large-rodent]
random_pet.website: Creation complete after 0s [id=overly-preferably-happily-lucky-warthog]
module.bucket.aws_s3_bucket.this: Creating...
module.website.aws_s3_bucket.this: Creating...
module.bucket.aws_s3_bucket.this: Still creating... [10s elapsed]
module.website.aws_s3_bucket.this: Still creating... [10s elapsed]
module.bucket.aws_s3_bucket.this: Creation complete after 12s [id=hugely-solely-eagerly-large-rodent]
module.website.aws_s3_bucket.this: Creation complete after 13s [id=overly-preferably-happily-lucky-warthog]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/index.html]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket-arn = "arn:aws:s3:::hugely-solely-eagerly-large-rodent"
bucket-name = "hugely-solely-eagerly-large-rodent"
bucket-website-arn = "arn:aws:s3:::overly-preferably-happily-lucky-warthog"
bucket-website-files = [
  "error.html",
  "index.html",
]
bucket-website-name = "overly-preferably-happily-lucky-warthog"
bucket-website-url = "overly-preferably-happily-lucky-warthog.s3-website-us-east-1.amazonaws.com"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~



# Website

- Na nossa pasta "website" temos 2 arquivos:
error.html
index.html
Estes 2 arquivos são usados na criação do site estático no bucket do S3.

- Usaremos o recurso "s3_bucket" do Terraform:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>

- Static Website Hosting
NOTE:
The parameter website is deprecated. Use the resource aws_s3_bucket_website_configuration instead.
O site do Terraform indica que a criação do parametro website está depreciada e indica o uso do recurso "aws_s3_bucket_website_configuration" no lugar dele.
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration>

- Forma depreciada, indicada pelo site do "s3_bucket":

~~~hcl
resource "aws_s3_bucket" "b" {
  bucket = "s3-website-test.hashicorp.com"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}
~~~


- Exemplo usando a nova versão.
- Resource: aws_s3_bucket_website_configuration
    Provides an S3 bucket website configuration resource. For more information, see Hosting Websites on S3.

- Example Usage
~~~hcl
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
~~~


- Nos 2 exemplos são mostradas as "routing_rule", mas não iremos usar elas.
- Iremos usar o "website".


- Exemplo editado do "main.tf" de dentro do s3_module, como ficaria se fossemos usar o módulo original:

~~~hcl
resource "aws_s3_bucket" "this" {
  bucket = "s3-website-test.hashicorp.com"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
~~~



- Se formos tentar aplicar isto, ao tentar criar o bucket do "main.tf" da raíz, ele vai tentar alterar o Bucket do S3 e colocar a parte de Website nele, mesmo que a gente queira criar um Bucket simples. Para resolver isto, podemos usar no módulo do S3 uma feature do Terraform que é o "Dynamic Blocks".
Usando o "Dynamic Blocks" passamos uma condição para o Terraform criar aquele recurso, dependendo da condição ele faz uma coisa.


- Como o for_each pode substituir o count, eles tem funcionalidades parecidas.
- No nosso caso vamos usar o for_each, pois podemos acessar informações especificas da nossa lista.
