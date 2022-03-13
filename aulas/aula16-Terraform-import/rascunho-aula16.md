


# Aula 16. Terraform import


- Cada recurso tem uma maneira de ser importado via terraform import, por isso, é necessário verificar na documentação como seguir com o import daquele recurso.


- Na aula 8 criamos um bucket manualmente, mas este bucket não está sendo gerenciado pelo Terraform.


# Import
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import
S3 bucket can be imported using the bucket, e.g.,
~~~bash
$ terraform import aws_s3_bucket.bucket bucket-name
terraform import aws_s3_bucket.bucket bucket-name
terraform import aws_s3_bucket.bucket meubucketcriadomanualmenteparaaula8cleber
~~~



- Tentando importar o bucket, apresenta um erro, pois o recurso não tem uma configuração no módulo da raíz:
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform import aws_s3_bucket.bucket meubucketcriadomanualmenteparaaula8cleber
Error: resource address "aws_s3_bucket.bucket" does not exist in the configuration.

Before importing this resource, please create its configuration in the root module. For example:

resource "aws_s3_bucket" "bucket" {
  # (resource arguments)
}

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~



- Criada a configuração necessária no s3.tf
- Necessário informar as tags que existem no recurso.
- Configuração do bucket manual para poder fazer o import ficará assim:
~~~hcl
resource "aws_s3_bucket" "manual" {
    bucket = "meubucketcriadomanualmenteparaaula8cleber"
    tags = {
      "Owner" = "Fernando Müller"
      "Criado" = "27/02/2021"
    }
}
~~~




- Para importar corretamente, precisamos ajustar o nome do recurso, para o nome do recurso que criamos, que é o "manual".
- Usar o novo comando terraform import, indicando o bucket manual:

~~~bash
terraform import aws_s3_bucket.manual meubucketcriadomanualmenteparaaula8cleber
~~~

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ terraform import aws_s3_bucket.manual meubucketcriadomanualmenteparaaula8cleber
aws_s3_bucket.manual: Importing from ID "meubucketcriadomanualmenteparaaula8cleber"...
aws_s3_bucket.manual: Import prepared!
  Prepared aws_s3_bucket for import
aws_s3_bucket.manual: Refreshing state... [id=meubucketcriadomanualmenteparaaula8cleber]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$
~~~







- Usando o terraform console para obter os valores do recurso manual:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ terraform console
> aws_s3_bucket.manual
{
  "acceleration_status" = ""
  "acl" = "private"
  "arn" = "arn:aws:s3:::meubucketcriadomanualmenteparaaula8cleber"
  "bucket" = "meubucketcriadomanualmenteparaaula8cleber"
  "bucket_domain_name" = "meubucketcriadomanualmenteparaaula8cleber.s3.amazonaws.com"
  "bucket_prefix" = tostring(null)
  "bucket_regional_domain_name" = "meubucketcriadomanualmenteparaaula8cleber.s3.amazonaws.com"
  "cors_rule" = tolist([])
  "force_destroy" = tobool(null)
  "grant" = toset([])
  "hosted_zone_id" = "Z3AQBSTGFYJSTF"
  "id" = "meubucketcriadomanualmenteparaaula8cleber"
  "lifecycle_rule" = tolist([])
  "logging" = toset([])
  "object_lock_configuration" = tolist([])
  "policy" = ""
  "region" = "us-east-1"
  "replication_configuration" = tolist([])
  "request_payer" = "BucketOwner"
  "server_side_encryption_configuration" = tolist([])
  "tags" = tomap({
    "Criado" = "27/02/2021"
    "Owner" = "Fernando Müller"
  })
  "tags_all" = tomap({
    "Criado" = "27/02/2021"
    "Owner" = "Fernando Müller"
  })
  "versioning" = tolist([
    {
      "enabled" = false
      "mfa_delete" = false
    },
  ])
  "website" = tolist([])
  "website_domain" = tostring(null)
  "website_endpoint" = tostring(null)
}
>




> aws_s3_bucket.manual.bucket
"meubucketcriadomanualmenteparaaula8cleber"
>



 550  cd ..
  551  cd aula16-Terraform-import/
  552  terraform import aws_s3_bucket.manual meubucketcriadomanualmenteparaaula8cleber
  553  terraform init
  554  terraform import aws_s3_bucket.manual meubucketcriadomanualmenteparaaula8cleber
  555  terraform console






- Editando o arquivo s3.tf, modificando o recurso do bucket manual.
- Adicionas as tags:
    Importado = "23/01/2021"
    ManagedBy = "Terraform"


- Executando o plan, ele indica que serão adicionadas 2 tags ao recurso:

terraform plan -out="tfplan.out"
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ terraform plan -out="tfplan.out"

random_pet.bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect]
aws_s3_bucket.super-bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect-dev]
aws_s3_bucket.manual: Refreshing state... [id=meubucketcriadomanualmenteparaaula8cleber]
aws_s3_object.random: Refreshing state... [id=config/violently-carefully-socially-healthy-insect.json]
aws_s3_object.objeto-do-bucket: Refreshing state... [id=config/ips.json]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.manual will be updated in-place
  ~ resource "aws_s3_bucket" "manual" {
      + force_destroy                        = false
        id                                   = "meubucketcriadomanualmenteparaaula8cleber"
      ~ tags                                 = {
          + "Importado" = "13/03/2022"
          + "ManagedBy" = "Terraform"
            # (2 unchanged elements hidden)
        }
      ~ tags_all                             = {
          + "Importado" = "13/03/2022"
          + "ManagedBy" = "Terraform"
            # (2 unchanged elements hidden)
        }
        # (16 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan.out"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$
~~~




terraform apply "tfplan.out"
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ terraform apply "tfplan.out"

aws_s3_bucket.manual: Modifying... [id=meubucketcriadomanualmenteparaaula8cleber]
aws_s3_bucket.manual: Modifications complete after 4s [id=meubucketcriadomanualmenteparaaula8cleber]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
bucket_domain_name = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
bucket_name = "violently-carefully-socially-healthy-insect-dev"
ips_file_path = "violently-carefully-socially-healthy-insect-dev/config/ips.json"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$
~~~




- Conferindo no bucket do S3, as alterações foram adicionadas com sucesso.
- Bucket passou a ser gerenciado pelo Terraform.



# Destroy

- Efetuando o terraform destroy, agora ele vai contemplar o bucket que havia sido criado manualmente no passado, visto que foi feito o import.
    terraform destroy
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ terraform destroy
random_pet.bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect]
aws_s3_bucket.manual: Refreshing state... [id=meubucketcriadomanualmenteparaaula8cleber]
aws_s3_bucket.super-bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect-dev]
aws_s3_object.objeto-do-bucket: Refreshing state... [id=config/ips.json]
aws_s3_object.random: Refreshing state... [id=config/violently-carefully-socially-healthy-insect.json]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.manual will be destroyed
  - resource "aws_s3_bucket" "manual" {
      - acl                                  = "private" -> null
      - arn                                  = "arn:aws:s3:::meubucketcriadomanualmenteparaaula8cleber" -> null
      - bucket                               = "meubucketcriadomanualmenteparaaula8cleber" -> null
      - bucket_domain_name                   = "meubucketcriadomanualmenteparaaula8cleber.s3.amazonaws.com" -> null
      - bucket_regional_domain_name          = "meubucketcriadomanualmenteparaaula8cleber.s3.amazonaws.com" -> null
      - cors_rule                            = [] -> null
      - force_destroy                        = false -> null
      - grant                                = [] -> null
      - hosted_zone_id                       = "Z3AQBSTGFYJSTF" -> null
      - id                                   = "meubucketcriadomanualmenteparaaula8cleber" -> null
      - lifecycle_rule                       = [] -> null
      - logging                              = [] -> null
      - region                               = "us-east-1" -> null
      - replication_configuration            = [] -> null
      - request_payer                        = "BucketOwner" -> null
      - server_side_encryption_configuration = [] -> null
      - tags                                 = {
          - "Criado"    = "27/02/2021"
          - "Importado" = "13/03/2022"
          - "ManagedBy" = "Terraform"
          - "Owner"     = "Fernando Müller"
        } -> null
      - tags_all                             = {
          - "Criado"    = "27/02/2021"
          - "Importado" = "13/03/2022"
          - "ManagedBy" = "Terraform"
          - "Owner"     = "Fernando Müller"
        } -> null
      - versioning                           = [
          - {
              - enabled    = false
              - mfa_delete = false
            },
        ] -> null
      - website                              = [] -> null
    }

  # aws_s3_bucket.super-bucket will be destroyed
  - resource "aws_s3_bucket" "super-bucket" {
      - acl                                  = "private" -> null
      - arn                                  = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev" -> null
      - bucket                               = "violently-carefully-socially-healthy-insect-dev" -> null
      - bucket_domain_name                   = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com" -> null
      - bucket_regional_domain_name          = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com" -> null
      - cors_rule                            = [] -> null
      - force_destroy                        = false -> null
      - grant                                = [] -> null
      - hosted_zone_id                       = "Z3AQBSTGFYJSTF" -> null
      - id                                   = "violently-carefully-socially-healthy-insect-dev" -> null
      - lifecycle_rule                       = [] -> null
      - logging                              = [] -> null
      - region                               = "us-east-1" -> null
      - replication_configuration            = [] -> null
      - request_payer                        = "BucketOwner" -> null
      - server_side_encryption_configuration = [] -> null
      - tags                                 = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
      - tags_all                             = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
      - versioning                           = [
          - {
              - enabled    = false
              - mfa_delete = false
            },
        ] -> null
      - website                              = [] -> null
    }

  # aws_s3_object.objeto-do-bucket will be destroyed
  - resource "aws_s3_object" "objeto-do-bucket" {
      - acl                = "private" -> null
      - bucket             = "violently-carefully-socially-healthy-insect-dev" -> null
      - bucket_key_enabled = false -> null
      - content_type       = "application/json" -> null
      - etag               = "c52a8f538af6722025af67dbdf094ded" -> null
      - force_destroy      = false -> null
      - id                 = "config/ips.json" -> null
      - key                = "config/ips.json" -> null
      - metadata           = {} -> null
      - source             = "ips.json" -> null
      - storage_class      = "STANDARD" -> null
      - tags               = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
      - tags_all           = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
    }

  # aws_s3_object.random will be destroyed
  - resource "aws_s3_object" "random" {
      - acl                = "private" -> null
      - bucket             = "violently-carefully-socially-healthy-insect-dev" -> null
      - bucket_key_enabled = false -> null
      - content_type       = "application/json" -> null
      - etag               = "c52a8f538af6722025af67dbdf094ded" -> null
      - force_destroy      = false -> null
      - id                 = "config/violently-carefully-socially-healthy-insect.json" -> null
      - key                = "config/violently-carefully-socially-healthy-insect.json" -> null
      - metadata           = {} -> null
      - source             = "ips.json" -> null
      - storage_class      = "STANDARD" -> null
      - tags               = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
      - tags_all           = {
          - "Environment" = "dev"
          - "Managedby"   = "Terraform"
          - "Name"        = "Meu Super Bucket"
          - "Owner"       = "Fernando Müller"
          - "Project"     = "Curso do Cleber"
          - "UpdatedAt"   = "06-02-2022"
        } -> null
    }

  # random_pet.bucket will be destroyed
  - resource "random_pet" "bucket" {
      - id        = "violently-carefully-socially-healthy-insect" -> null
      - length    = 5 -> null
      - separator = "-" -> null
    }

Plan: 0 to add, 0 to change, 5 to destroy.

Changes to Outputs:
  - bucket_arn         = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev" -> null
  - bucket_domain_name = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com" -> null
  - bucket_name        = "violently-carefully-socially-healthy-insect-dev" -> null
  - ips_file_path      = "violently-carefully-socially-healthy-insect-dev/config/ips.json" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_s3_object.objeto-do-bucket: Destroying... [id=config/ips.json]
aws_s3_object.random: Destroying... [id=config/violently-carefully-socially-healthy-insect.json]
aws_s3_bucket.manual: Destroying... [id=meubucketcriadomanualmenteparaaula8cleber]
aws_s3_object.random: Destruction complete after 1s
aws_s3_object.objeto-do-bucket: Destruction complete after 1s
aws_s3_bucket.super-bucket: Destroying... [id=violently-carefully-socially-healthy-insect-dev]
aws_s3_bucket.manual: Destruction complete after 1s
aws_s3_bucket.super-bucket: Destruction complete after 0s
random_pet.bucket: Destroying... [id=violently-carefully-socially-healthy-insect]
random_pet.bucket: Destruction complete after 0s

Destroy complete! Resources: 5 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula16-Terraform-import$ ^C
~~~