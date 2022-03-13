

# Aula 15. O arquivo de estado tfstate


# O que é o Terraform State?

O Terraform State é uma forma do Terraform gerenciar a infra, configurações e os recursos criados afim de manter um mapeamento do que já existe e controlar a atualização e criação de novos recursos.

Um exemplo básico é quando criamos um Bucket S3, um EC2 ou uma SQS via Terraform. Todos estes recursos são mapeados no estado e passam a ser gerenciados pelo Terraform.
 

# Localização do State

## Local 

Por padrão o Terraform aloca o estado localmente no arquivo terraform.tfsate. Utilizar o State localmente pode funcionar bem para um estudo específico no qual não exista a necessidade em compartilhar o State entre times.

## Remote 

Ao contrário do Local, quando temos times compartilhando dos mesmos recursos, a utilização do State de forma remota se torna imprescindível. O Terraform provê suporte para que o State possa ser compartilhado de forma remota. Não entraremos em detalhes em como configurar, mas é possível manter o State no Amazon S3, Azure Blob Storage, Google Cloud Storage, Alibaba Cloud OSS e entre outras nuvens. 

O State é representado pelo arquivo terraform.tfsate, um arquivo no formato JSON




o Terraform verifica no arquivo terraform.tfstate o estado dos recursos.




# Editando e verificando o estado

- Editar o arquivo s3.tf, adicionando um objeto que vai pegar o nome do bucket que foi criado via Random.
- Adicionar a extensão json ao arquivo/objeto.
~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"

  tags = local.common_tags
}

resource "aws_s3_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${local.ip_filepath}"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
}

resource "aws_s3_object" "random" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${random_pet.bucket.id}.json"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
}
~~~





  526  cd aula15-O-arquivo-de-estado-tfstate/
  527  ls
  528  terraform plan -out="tfplan.out"
  529  terraform plan -out="tfplan.out"
  530  terraform init
  531  terraform plan -out="tfplan.out"
  532  terraform show
  533  terraform apply "tfplan.out"
  534  history | tail -n 12

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform apply "tfplan.out"
aws_s3_bucket.super-bucket: Creating...
aws_s3_bucket.super-bucket: Creation complete after 4s [id=violently-carefully-socially-healthy-insect-dev]
aws_s3_object.random: Creating...
aws_s3_object.objeto-do-bucket: Creating...
aws_s3_object.random: Creation complete after 1s [id=config/violently-carefully-socially-healthy-insect.json]
aws_s3_object.objeto-do-bucket: Creation complete after 1s [id=config/ips.json]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
bucket_domain_name = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
bucket_name = "violently-carefully-socially-healthy-insect-dev"
ips_file_path = "violently-carefully-socially-healthy-insect-dev/config/ips.json"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~




- Conforme os Outputs, foram gerados o bucket e 2 objetos.


- Usando o comando "terraform show" é possível verificar o estado do terraform state.
    show          Show the current state or a saved plan


~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform show
# aws_s3_bucket.super-bucket:
resource "aws_s3_bucket" "super-bucket" {
    acl                                  = "private"
    arn                                  = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
    bucket                               = "violently-carefully-socially-healthy-insect-dev"
    bucket_domain_name                   = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
    bucket_regional_domain_name          = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
    cors_rule                            = []
    force_destroy                        = false
    grant                                = []
    hosted_zone_id                       = "Z3AQBSTGFYJSTF"
    id                                   = "violently-carefully-socially-healthy-insect-dev"
    lifecycle_rule                       = []
    logging                              = []
    region                               = "us-east-1"
    replication_configuration            = []
    request_payer                        = "BucketOwner"
    server_side_encryption_configuration = []
    tags                                 = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
    tags_all                             = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
    versioning                           = [
        {
            enabled    = false
            mfa_delete = false
        },
    ]
    website                              = []
}

# aws_s3_object.objeto-do-bucket:
resource "aws_s3_object" "objeto-do-bucket" {
    acl                = "private"
    bucket             = "violently-carefully-socially-healthy-insect-dev"
    bucket_key_enabled = false
    content_type       = "binary/octet-stream"
    etag               = "c52a8f538af6722025af67dbdf094ded"
    force_destroy      = false
    id                 = "config/ips.json"
    key                = "config/ips.json"
    source             = "ips.json"
    storage_class      = "STANDARD"
    tags               = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
    tags_all           = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
}

# aws_s3_object.random:
resource "aws_s3_object" "random" {
    acl                = "private"
    bucket             = "violently-carefully-socially-healthy-insect-dev"
    bucket_key_enabled = false
    content_type       = "binary/octet-stream"
    etag               = "c52a8f538af6722025af67dbdf094ded"
    force_destroy      = false
    id                 = "config/violently-carefully-socially-healthy-insect.json"
    key                = "config/violently-carefully-socially-healthy-insect.json"
    source             = "ips.json"
    storage_class      = "STANDARD"
    tags               = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
    tags_all           = {
        "Environment" = "dev"
        "Managedby"   = "Terraform"
        "Name"        = "Meu Super Bucket"
        "Owner"       = "Fernando Müller"
        "Project"     = "Curso do Cleber"
        "UpdatedAt"   = "06-02-2022"
    }
}

# random_pet.bucket:
resource "random_pet" "bucket" {
    id        = "violently-carefully-socially-healthy-insect"
    length    = 5
    separator = "-"
}


Outputs:

bucket_arn = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
bucket_domain_name = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
bucket_name = "violently-carefully-socially-healthy-insect-dev"
ips_file_path = "violently-carefully-socially-healthy-insect-dev/config/ips.json"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~



- Usando o comando "terraform show --json", ele traz a mesma saída, mas removendo todos os espaços e as quebras de linhas:
~~~json
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform show --json
{"format_version":"1.0","terraform_version":"1.1.5","values":{"outputs":{"bucket_arn":{"sensitive":false,"value":"arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"},"bucket_domain_name":{"sensitive":false,"value":"violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"},"bucket_name":{"sensitive":false,"value":"violently-carefully-socially-healthy-insect-dev"},"ips_file_path":{"sensitive":false,"value":"violently-carefully-socially-healthy-insect-dev/config/ips.json"}},"root_module":{"resources":[{"address":"aws_s3_bucket.super-bucket","mode":"managed","type":"aws_s3_bucket","name":"super-bucket","provider_name":"registry.terraform.io/hashicorp/aws","schema_version":0,"values":{"acceleration_status":"","acl":"private","arn":"arn:aws:s3:::violently-carefully-socially-healthy-insect-dev","bucket":"violently-carefully-socially-healthy-insect-dev","bucket_domain_name":"violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com","bucket_prefix":null,"bucket_regional_domain_name":"violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com","cors_rule":[],"force_destroy":false,"grant":[],"hosted_zone_id":"Z3AQBSTGFYJSTF","id":"violently-carefully-socially-healthy-insect-dev","lifecycle_rule":[],"logging":[],"object_lock_configuration":[],"policy":"","region":"us-east-1","replication_configuration":[],"request_payer":"BucketOwner","server_side_encryption_configuration":[],"tags":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"tags_all":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"versioning":[{"enabled":false,"mfa_delete":false}],"website":[],"website_domain":null,"website_endpoint":null},"sensitive_values":{"cors_rule":[],"grant":[],"lifecycle_rule":[],"logging":[],"object_lock_configuration":[],"replication_configuration":[],"server_side_encryption_configuration":[],"tags":{},"tags_all":{},"versioning":[{}],"website":[]},"depends_on":["random_pet.bucket"]},{"address":"aws_s3_object.objeto-do-bucket","mode":"managed","type":"aws_s3_object","name":"objeto-do-bucket","provider_name":"registry.terraform.io/hashicorp/aws","schema_version":0,"values":{"acl":"private","bucket":"violently-carefully-socially-healthy-insect-dev","bucket_key_enabled":false,"cache_control":"","content":null,"content_base64":null,"content_disposition":"","content_encoding":"","content_language":"","content_type":"binary/octet-stream","etag":"c52a8f538af6722025af67dbdf094ded","force_destroy":false,"id":"config/ips.json","key":"config/ips.json","kms_key_id":null,"metadata":null,"object_lock_legal_hold_status":"","object_lock_mode":"","object_lock_retain_until_date":"","server_side_encryption":"","source":"ips.json","source_hash":null,"storage_class":"STANDARD","tags":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"tags_all":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"version_id":"","website_redirect":""},"sensitive_values":{"tags":{},"tags_all":{}},"depends_on":["aws_s3_bucket.super-bucket","random_pet.bucket"]},{"address":"aws_s3_object.random","mode":"managed","type":"aws_s3_object","name":"random","provider_name":"registry.terraform.io/hashicorp/aws","schema_version":0,"values":{"acl":"private","bucket":"violently-carefully-socially-healthy-insect-dev","bucket_key_enabled":false,"cache_control":"","content":null,"content_base64":null,"content_disposition":"","content_encoding":"","content_language":"","content_type":"binary/octet-stream","etag":"c52a8f538af6722025af67dbdf094ded","force_destroy":false,"id":"config/violently-carefully-socially-healthy-insect.json","key":"config/violently-carefully-socially-healthy-insect.json","kms_key_id":null,"metadata":null,"object_lock_legal_hold_status":"","object_lock_mode":"","object_lock_retain_until_date":"","server_side_encryption":"","source":"ips.json","source_hash":null,"storage_class":"STANDARD","tags":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"tags_all":{"Environment":"dev","Managedby":"Terraform","Name":"Meu Super Bucket","Owner":"Fernando Müller","Project":"Curso do Cleber","UpdatedAt":"06-02-2022"},"version_id":"","website_redirect":""},"sensitive_values":{"tags":{},"tags_all":{}},"depends_on":["aws_s3_bucket.super-bucket","random_pet.bucket"]},{"address":"random_pet.bucket","mode":"managed","type":"random_pet","name":"bucket","provider_name":"registry.terraform.io/hashicorp/random","schema_version":0,"values":{"id":"violently-carefully-socially-healthy-insect","keepers":null,"length":5,"prefix":null,"separator":"-"},"sensitive_values":{}}]}}}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~





- Ajustando o tipo de conteúdo dos nossos objetos.

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object#content_type
    content_type - (Optional) Standard MIME type describing the format of the object data, e.g., application/octet-stream. All Valid MIME Types are valid for this input.

- Editar o arquivo s3.tf.
- Adicionar o content_type
- No terraform show e no state, está assim:
    "content_type": "binary/octet-stream"
- Colocar no arquivo s3.tf:
    content_type = "application/json"
Observação:
 este content_type = "application/json" é um bom candidato para ser adicionado ao locals, pois se repete mais de 1x.

- Novo arquivo s3.tf, após adicionando o content type:
~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"

  tags = local.common_tags
}

resource "aws_s3_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${local.ip_filepath}"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
    content_type = "application/json"
}

resource "aws_s3_object" "random" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${random_pet.bucket.id}.json"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
    content_type = "application/json"
}
~~~



- Validar e aplicar as alterações:
  531  terraform plan -out="tfplan.out"
  532  terraform show
  533  terraform apply "tfplan.out"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform plan -out="tfplan.out"
random_pet.bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect]
aws_s3_bucket.super-bucket: Refreshing state... [id=violently-carefully-socially-healthy-insect-dev]
aws_s3_object.objeto-do-bucket: Refreshing state... [id=config/ips.json]
aws_s3_object.random: Refreshing state... [id=config/violently-carefully-socially-healthy-insect.json]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_s3_object.objeto-do-bucket has changed
  ~ resource "aws_s3_object" "objeto-do-bucket" {
        id                 = "config/ips.json"
      + metadata           = {}
        tags               = {
            "Environment" = "dev"
            "Managedby"   = "Terraform"
            "Name"        = "Meu Super Bucket"
            "Owner"       = "Fernando Müller"
            "Project"     = "Curso do Cleber"
            "UpdatedAt"   = "06-02-2022"
        }
        # (10 unchanged attributes hidden)
    }

  # aws_s3_object.random has changed
  ~ resource "aws_s3_object" "random" {
        id                 = "config/violently-carefully-socially-healthy-insect.json"
      + metadata           = {}
        tags               = {
            "Environment" = "dev"
            "Managedby"   = "Terraform"
            "Name"        = "Meu Super Bucket"
            "Owner"       = "Fernando Müller"
            "Project"     = "Curso do Cleber"
            "UpdatedAt"   = "06-02-2022"
        }
        # (10 unchanged attributes hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to these changes.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_object.objeto-do-bucket will be updated in-place
  ~ resource "aws_s3_object" "objeto-do-bucket" {
      ~ content_type       = "binary/octet-stream" -> "application/json"
        id                 = "config/ips.json"
        tags               = {
            "Environment" = "dev"
            "Managedby"   = "Terraform"
            "Name"        = "Meu Super Bucket"
            "Owner"       = "Fernando Müller"
            "Project"     = "Curso do Cleber"
            "UpdatedAt"   = "06-02-2022"
        }
      + version_id         = (known after apply)
        # (10 unchanged attributes hidden)
    }

  # aws_s3_object.random will be updated in-place
  ~ resource "aws_s3_object" "random" {
      ~ content_type       = "binary/octet-stream" -> "application/json"
        id                 = "config/violently-carefully-socially-healthy-insect.json"
        tags               = {
            "Environment" = "dev"
            "Managedby"   = "Terraform"
            "Name"        = "Meu Super Bucket"
            "Owner"       = "Fernando Müller"
            "Project"     = "Curso do Cleber"
            "UpdatedAt"   = "06-02-2022"
        }
      + version_id         = (known after apply)
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 2 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan.out"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform apply "tfplan.out"
aws_s3_object.objeto-do-bucket: Modifying... [id=config/ips.json]
aws_s3_object.random: Modifying... [id=config/violently-carefully-socially-healthy-insect.json]
aws_s3_object.random: Modifications complete after 1s [id=config/violently-carefully-socially-healthy-insect.json]
aws_s3_object.objeto-do-bucket: Modifications complete after 1s [id=config/ips.json]

Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
bucket_domain_name = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
bucket_name = "violently-carefully-socially-healthy-insect-dev"
ips_file_path = "violently-carefully-socially-healthy-insect-dev/config/ips.json"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~





# Comando terraform console

The terraform console command provides an interactive console for evaluating expressions.

- Usando o comando "terraform console" é possível executar comandos interativos na console e obter valores dos recursos.

- Exemplos:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform console
> 1 +5
6
>



aws_s3_bucket.super-bucket


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform console
> 1 +5
6
> aws_s3_bucket.super-bucket
{
  "acceleration_status" = ""
  "acl" = "private"
  "arn" = "arn:aws:s3:::violently-carefully-socially-healthy-insect-dev"
  "bucket" = "violently-carefully-socially-healthy-insect-dev"
  "bucket_domain_name" = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
  "bucket_prefix" = tostring(null)
  "bucket_regional_domain_name" = "violently-carefully-socially-healthy-insect-dev.s3.amazonaws.com"
  "cors_rule" = tolist([])
  "force_destroy" = false
  "grant" = toset([])
  "hosted_zone_id" = "Z3AQBSTGFYJSTF"
  "id" = "violently-carefully-socially-healthy-insect-dev"
  "lifecycle_rule" = tolist([])
  "logging" = toset([])
  "object_lock_configuration" = tolist([])
  "policy" = ""
  "region" = "us-east-1"
  "replication_configuration" = tolist([])
  "request_payer" = "BucketOwner"
  "server_side_encryption_configuration" = tolist([])
  "tags" = tomap({
    "Environment" = "dev"
    "Managedby" = "Terraform"
    "Name" = "Meu Super Bucket"
    "Owner" = "Fernando Müller"
    "Project" = "Curso do Cleber"
    "UpdatedAt" = "06-02-2022"
  })
  "tags_all" = tomap({
    "Environment" = "dev"
    "Managedby" = "Terraform"
    "Name" = "Meu Super Bucket"
    "Owner" = "Fernando Müller"
    "Project" = "Curso do Cleber"
    "UpdatedAt" = "06-02-2022"
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





> aws_s3_bucket.super-bucket.region
"us-east-1"
>





- Comando para listar os recursos que foram criados e estão no state:
terraform state list
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$ terraform state list
aws_s3_bucket.super-bucket
aws_s3_object.objeto-do-bucket
aws_s3_object.random
random_pet.bucket
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula15-O-arquivo-de-estado-tfstate$
~~~