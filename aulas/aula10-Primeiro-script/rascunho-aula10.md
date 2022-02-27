


# Aula 10. Primeiro script

- Acessar o site do Terraform e ir no Provider AWS:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs>

- Procurar na documentação por S3 > aws_s3_bucket:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>


- Copiar as entradas do arquivo .gitignore do material, para o arquivo .gitignore do projeto das aulas do curso.

~~~bash
*.dll
*.exe
.DS_Store
example.tf
terraform.tfplan
terraform.tfstate
bin/
modules-dev/
/pkg/
website/.vagrant
website/.bundle
website/build
website/node_modules
.vagrant/
*.backup
./*.tfstate
.terraform/
*.log
*.bak
*~
.*.swp
.idea
*.iml
*.test
*.iml

website/vendor

# Test exclusions
!command/test-fixtures/**/*.tfstate
!command/test-fixtures/**/.terraform/

node_modules/
*.zip
tfplan.out
plan.tfout
~~~



- Ficando assim o nosso arquivo:

~~~bash
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Ignore any .tfvars files that are generated automatically for each Terraform run. Most
# .tfvars files are managed as part of configuration and so should be included in
# version control.
#
# example.tfvars

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
#
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*


*.dll
*.exe
.DS_Store
example.tf
terraform.tfplan
terraform.tfstate
bin/
modules-dev/
/pkg/
website/.vagrant
website/.bundle
website/build
website/node_modules
.vagrant/
*.backup
./*.tfstate
.terraform/
*.log
*.bak
*~
.*.swp
.idea
*.iml
*.test
*.iml

website/vendor

# Test exclusions
!command/test-fixtures/**/*.tfstate
!command/test-fixtures/**/.terraform/

node_modules/
*.zip
tfplan.out
plan.tfout
~~~



## Criando arquivo main

- Primeiro passo é criar um arquivo chamado "main.tf" na pasta do projeto.

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script/main.tf
~~~

- Copiar no site do Terraform o bloco de código que cria o Bucket do S3.
- Definir o provider AWS no código do main.tf.
- Colar o bloco de código do bucket do S3.

- Exemplo do site da Terraform:

~~~hcl
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
~~~


- Ajustar o bloco de código.
- Adicionar a tag de managed by Terraform:
    Managedby   = "Terraform"

- Código do main.tf ficará assim:

~~~hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket-teste" {
  bucket = "meu-bucket-de-teste-via-terraform-27-02-2022"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "acl-de-exemplo" {
  bucket = aws_s3_bucket.bucket-teste.id
  acl    = "private"
}
~~~



- Com o código configurado, agora é necessário rodar o comando "terraform init" dentro do diretório do projeto:
~~~bash
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script
terraform init
~~~


- Saída esperada:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v4.2.0...
- Installed hashicorp/aws v4.2.0 (signed by HashiCorp)

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$
~~~



- Na saída temos a informação que o Terraform criou um arquivo ".terraform.lock.hcl"
- Este arquivo contem informações da versão do provider.

- Resultado:

~~~hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version = "4.2.0"
  hashes = [
    "h1:qfnMtwFbsVJWvzxUCajm4zUkjEH9GDdT3FFYffEEhYQ=",
    "zh:297d6462055eac8eb5c6735bd1a0fec23574e27d56c4c14a39efd8f3931ce4ed",
    "zh:457319839adca3638fd76f49fd65e15756717f97ac99bd1805a1c9387a62a250",
    "zh:57377384fa28abc4211a0916fc0fb590af238d096ad0490434ffeb89f568df9b",
    "zh:578e1d21bd6d38bdaef0909b30959b884e84e6c464796a50e516822955db162a",
    "zh:5e7ff13cc976f609aee4ada3c1967ba1f0ce5d276f3102a0aeaedc586d25ea80",
    "zh:5e94f09fe1874a2365bd566fecab8f676cd720da1c0bf70875392679549ebf20",
    "zh:93da14d7ffb8550b161cb79fe2cfc0f66848dd5022974399ae2bf88da7b9e9c5",
    "zh:c51e4541f3d29627974dcb7f5919012a762391accb574ade9e28bdb3c92bada5",
    "zh:eff58c1680e3f29e514919346d937bbe47278434ae03ed62443c77e878e267b1",
    "zh:f2b749e6c6b77b26e643bbecc829977270cfefab106d5ea57e5a83e96d49cbdd",
    "zh:fcc17e60e55c278535c332469727cf215eaea9ec81d38e2b5f05be127ee39a5b",
  ]
}
~~~




## Terraform plan

- Executar o comando "terraform plan", para verificar as alterações que serão realizadas.

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste will be created
  + resource "aws_s3_bucket" "bucket-teste" {
      + acceleration_status                  = (known after apply)
      + acl                                  = (known after apply)
      + arn                                  = (known after apply)
      + bucket                               = "meu-bucket-de-teste-via-terraform-27-02-2022"
      + bucket_domain_name                   = (known after apply)
      + bucket_regional_domain_name          = (known after apply)
      + cors_rule                            = (known after apply)
      + force_destroy                        = false
      + grant                                = (known after apply)
      + hosted_zone_id                       = (known after apply)
      + id                                   = (known after apply)
      + lifecycle_rule                       = (known after apply)
      + logging                              = (known after apply)
      + policy                               = (known after apply)
      + region                               = (known after apply)
      + replication_configuration            = (known after apply)
      + request_payer                        = (known after apply)
      + server_side_encryption_configuration = (known after apply)
      + tags                                 = {
          + "Environment" = "Dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "My bucket"
        }
      + tags_all                             = {
          + "Environment" = "Dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "My bucket"
        }
      + versioning                           = (known after apply)
      + website                              = (known after apply)
      + website_domain                       = (known after apply)
      + website_endpoint                     = (known after apply)

      + object_lock_configuration {
          + object_lock_enabled = (known after apply)
          + rule                = (known after apply)
        }
    }

  # aws_s3_bucket_acl.acl-de-exemplo will be created
  + resource "aws_s3_bucket_acl" "acl-de-exemplo" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)

      + access_control_policy {
          + grant {
              + permission = (known after apply)

              + grantee {
                  + display_name  = (known after apply)
                  + email_address = (known after apply)
                  + id            = (known after apply)
                  + type          = (known after apply)
                  + uri           = (known after apply)
                }
            }

          + owner {
              + display_name = (known after apply)
              + id           = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$
~~~





## Terraform apply

- Para criar o bucket no S3 via Terraform, é necessário aplicar as configuraçãoes.
- Executar o comando:
~~~bash
terraform apply
~~~

- Resultado:

~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste will be created
  + resource "aws_s3_bucket" "bucket-teste" {
      + acceleration_status                  = (known after apply)
      + acl                                  = (known after apply)
      + arn                                  = (known after apply)
      + bucket                               = "meu-bucket-de-teste-via-terraform-27-02-2022"
      + bucket_domain_name                   = (known after apply)
      + bucket_regional_domain_name          = (known after apply)
      + cors_rule                            = (known after apply)
      + force_destroy                        = false
      + grant                                = (known after apply)
      + hosted_zone_id                       = (known after apply)
      + id                                   = (known after apply)
      + lifecycle_rule                       = (known after apply)
      + logging                              = (known after apply)
      + policy                               = (known after apply)
      + region                               = (known after apply)
      + replication_configuration            = (known after apply)
      + request_payer                        = (known after apply)
      + server_side_encryption_configuration = (known after apply)
      + tags                                 = {
          + "Environment" = "Dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "My bucket"
        }
      + tags_all                             = {
          + "Environment" = "Dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "My bucket"
        }
      + versioning                           = (known after apply)
      + website                              = (known after apply)
      + website_domain                       = (known after apply)
      + website_endpoint                     = (known after apply)

      + object_lock_configuration {
          + object_lock_enabled = (known after apply)
          + rule                = (known after apply)
        }
    }

  # aws_s3_bucket_acl.acl-de-exemplo will be created
  + resource "aws_s3_bucket_acl" "acl-de-exemplo" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)

      + access_control_policy {
          + grant {
              + permission = (known after apply)

              + grantee {
                  + display_name  = (known after apply)
                  + email_address = (known after apply)
                  + id            = (known after apply)
                  + type          = (known after apply)
                  + uri           = (known after apply)
                }
            }

          + owner {
              + display_name = (known after apply)
              + id           = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.bucket-teste: Creating...
aws_s3_bucket.bucket-teste: Creation complete after 4s [id=meu-bucket-de-teste-via-terraform-27-02-2022]
aws_s3_bucket_acl.acl-de-exemplo: Creating...
aws_s3_bucket_acl.acl-de-exemplo: Creation complete after 0s [id=meu-bucket-de-teste-via-terraform-27-02-2022,private]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script$
~~~





## Fixar a versão do Terraform

- É muito importante fixar a versão usada no Terraform, para evitar conflitos e problemas no futuro.
- Fixar a versão do Terraform, no caso é a 1.1.5.
- Fixar a versão do Provider, que pode ser verificada no arquivo terraform-aws/aulas/aula10-Primeiro-script/.terraform.lock.hcl. Versão 4.2.0.

- Código que é necessário adicionar ao main.tf:

~~~hcl
terraform {
  required_version = "1.1.5"
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "4.2.0"
    }
  }
}
~~~


- O novo script do main.tf ficará assim:

~~~hcl
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
  bucket = "meu-bucket-de-teste-via-terraform-27-02-2022"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "acl-de-exemplo" {
  bucket = aws_s3_bucket.bucket-teste.id
  acl    = "private"
}
~~~