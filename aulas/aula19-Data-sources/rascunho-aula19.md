

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

owners - (Required) List of AMI owners to limit search. At least 1 value must be specified. Valid values: an AWS account ID, self (the current account), or an AWS owner alias (e.g., amazon, aws-marketplace, microsoft).

most_recent - (Optional) If more than one result is returned, use the most recent AMI.

name_regex - (Optional) A regex string to apply to the AMI list returned by AWS. This allows more advanced filtering not supported from the AWS API. This filtering is done locally on what AWS returns, and could have a performance impact if the result is large. It is recommended to combine this with other options to narrow down the list AWS returns.



- Criar os arquivos Terraform da pasta EC2:

- data.tf

~~~hcl
data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "ubuntu"
}
~~~



- ec2.tf

~~~hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}
~~~



- main.tf

~~~hcl
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-816678621138"
    key     = "dev/03-data-sources-s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "fernandomuller"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
~~~




- outputs.tf

~~~hcl
output "id" {
  value = aws_instance.web.id
}

output "ami" {
  value = aws_instance.web.ami
}

output "arn" {
  value = aws_instance.web.arn
}
~~~



- variables.tf

~~~hcl
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

variable "instance_type" {
  type        = string
  description = ""
  default     = "t3a.micro"
}
~~~





- Será usado o Backend no S3, guardando o tfstate lá.



- Acessar a pasta com os Terraform da EC2, efetuar o init e o apply
terraform init
terraform apply

- Aconteceu um erro.
- O backend via S3 precisa ser para um bucket já existente.

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$ terraform init

Initializing the backend...
╷
│ Error: Failed to get existing workspaces: S3 bucket does not exist.
│
│ The referenced S3 bucket must have been previously created. If the S3 bucket
│ was created within the last minute, please wait for a minute or two and try
│ again.
│
│ Error: NoSuchBucket: The specified bucket does not exist
│       status code: 404, request id: 743HWMJCNJKBWVVK, host id: ZYtg3xrGsnS1ozDFmZfSoyeS6grDQHdwM8WpxkiIC/H2Cuz1Nes29khkZjXMEKm2Hs5GosX+LhM=
│
│
│
╵

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~




- Criando um arquivo chamado main.tf na pasta remote-state-bucket, para criar o bucket que vai servir para o Backend.
- Usada como referencia o arquivo abaixo:
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket/main.tf

~~~hcl
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "fernandomuller"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "remote-state" {
  bucket = "tfstate-${data.aws_caller_identity.current.account_id}"

  versioning {
    enabled = true
  }

  tags = {
    Description = "Stores terraform remote state files"
    ManagedBy   = "Terraform"
    Owner       = "Fernando Muller Junior"
    CreatedAt   = "2022-03-26"
  }
}

resource "aws_dynamodb_table" "lock-table" {
  name           = "tflock-${aws_s3_bucket.remote-state.bucket}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "remote_state_bucket" {
  value = aws_s3_bucket.remote-state.bucket
}

output "remote_state_bucket_arn" {
  value = aws_s3_bucket.remote-state.arn
}
~~~


- Acessando o diretório
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/remote-state-bucket

-Aplicando o bucket.
terraform init
terraform apply -auto-approve

~~~bash
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + remote_state_bucket     = "tfstate-816678621138"
  + remote_state_bucket_arn = (known after apply)
aws_s3_bucket.remote-state: Creating...
aws_s3_bucket.remote-state: Still creating... [10s elapsed]
aws_s3_bucket.remote-state: Creation complete after 12s [id=tfstate-816678621138]
aws_dynamodb_table.lock-table: Creating...
aws_dynamodb_table.lock-table: Creation complete after 10s [id=tflock-tfstate-816678621138]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

remote_state_bucket = "tfstate-816678621138"
remote_state_bucket_arn = "arn:aws:s3:::tfstate-816678621138"
~~~



- Criado o bucket:
tfstate-816678621138



- Acessando novamente a pasta dos Terraform da EC2, para aplicar o projeto do curso.
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2
terraform init
terraform apply -auto-approve


- Backend inicializado:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$ terraform init

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.23.0"...
- Installing hashicorp/aws v3.23.0...
- Installed hashicorp/aws v3.23.0 (signed by HashiCorp)
[...]
~~~

- Ocorreu um erro durante o apply, devido a arquitetura da AMI ser diferente do tipo de instancia:

~~~bash
│ Error: Error launching source instance: InvalidParameterValue: The architecture 'x86_64' of the specified instance type does not match the architecture 'arm64' of the specified AMI. Specify an instance type and an AMI that have matching architectures, and try again. You can use 'describe-instance-types' or 'describe-images' to discover the architecture of the instance type or AMI.
│       status code: 400, request id: 9e91e244-e995-42f1-bb8c-5ef3e4158223
│
│   with aws_instance.web,
│   on ec2.tf line 1, in resource "aws_instance" "web":
│    1: resource "aws_instance" "web" {
│
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~


- Foi necessário editar o arquivo data.tf e colocar um filtro no Data Source AMI:

~~~hcl
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
~~~

- Os valores que podem ser filtrados estão no site:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami>
<https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html>


- Novo arquivo data.tf:

~~~hcl
data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "ubuntu"
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
~~~


- Aplicado com sucesso, objeto com o tfstate encontra-se no bucket S3.

~~~bash
Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  ~ ami = "ami-09e5327e694d89ef4" -> "ami-015cfeb4e0d6306b2"
  + arn = (known after apply)
  + id  = (known after apply)
aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Creation complete after 19s [id=i-0826ad3d798627604]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ami = "ami-015cfeb4e0d6306b2"
arn = "arn:aws:ec2:us-east-1:816678621138:instance/i-0826ad3d798627604"
id = "i-0826ad3d798627604"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~


- O comando terraform output retorna valores de Outputs existentes:
terraform output ami

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$ terraform output ami
"ami-015cfeb4e0d6306b2"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~



- O comando terraform output retorna valores de Outputs existentes.
- Usando o comando sem parametros ele retorna todos os Outputs.

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$ terraform output
ami = "ami-015cfeb4e0d6306b2"
arn = "arn:aws:ec2:us-east-1:816678621138:instance/i-0826ad3d798627604"
id = "i-0826ad3d798627604"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~


- Usando o comando sem parametros ele retorna todos os Outputs.
- Podemos formatar a saída em JSON, usando o -json
terraform output -json

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$ terraform output -json
{
  "ami": {
    "sensitive": false,
    "type": "string",
    "value": "ami-015cfeb4e0d6306b2"
  },
  "arn": {
    "sensitive": false,
    "type": "string",
    "value": "arn:aws:ec2:us-east-1:816678621138:instance/i-0826ad3d798627604"
  },
  "id": {
    "sensitive": false,
    "type": "string",
    "value": "i-0826ad3d798627604"
  }
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/ec2$
~~~



- Salvando as informações dos Outputs num arquivo, para depois consumir elas.

terraform output -json > ../s3/outputs.json


- Criar arquivos do projeto na pasta s3:
~~~bash
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3
~~~

data.tf

~~~hcl
data "terraform_remote_state" "server" {
  backend = "s3"

  config = {
    bucket  = "tfstate-816678621138"
    key     = "dev/03-data-sources-s3/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
~~~


locals.tf

~~~hcl
locals {
  instance = {
    id  = data.terraform_remote_state.server.outputs.id
    ami = data.terraform_remote_state.server.outputs.ami
    arn = data.terraform_remote_state.server.outputs.arn
  }
}
~~~



main.tf

~~~hcl
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
~~~



outputs.tf

~~~hcl
output "server" {
  value = local.instance
}
~~~


s3.tf

~~~hcl
resource "random_pet" "this" {
  length = 5
}

resource "aws_s3_bucket" "this" {
  bucket = "my-bucket-${random_pet.this.id}"
}

resource "aws_s3_bucket_object" "this" {
  bucket       = aws_s3_bucket.this.bucket
  key          = "instances/instances-${local.instance.ami}.json"
  source       = "outputs.json"
  etag         = filemd5("outputs.json")
  content_type = "application/json"
}
~~~





- Os dados são acessados usando o Data Source "terraform_remote_state":

~~~hcl
data "terraform_remote_state" "server" {
  backend = "s3"

  config = {
    bucket  = "tfstate-816678621138"
    key     = "dev/03-data-sources-s3/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
~~~

- Usando locals para facilitar o acesso aos dados que precisamos.
- é criado um locals do tipo Objeto, que tem 3 valores que acessamos via Data Source terraform_remote_state.

~~~hcl
locals {
  instance = {
    id  = data.terraform_remote_state.server.outputs.id
    ami = data.terraform_remote_state.server.outputs.ami
    arn = data.terraform_remote_state.server.outputs.arn
  }
}
~~~



- Recurso aws_s3_bucket_object no Terraform:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object>
key - (Required) Name of the object once it is in the bucket.
source - (Optional, conflicts with content and content_base64) Path to a file that will be read and uploaded as raw bytes for the object content.
etag - (Optional) Triggers updates when the value changes. The only meaningful value is filemd5("path/to/file") (Terraform 0.11.12 or later) or ${md5(file("path/to/file"))} (Terraform 0.11.11 or earlier). This attribute is not compatible with KMS encryption, kms_key_id or server_side_encryption = "aws:kms" (see source_hash instead).

~~~hcl
resource "aws_s3_bucket_object" "this" {
  bucket       = aws_s3_bucket.this.bucket
  key          = "instances/instances-${local.instance.ami}.json"
  source       = "outputs.json"
  etag         = filemd5("outputs.json")
  content_type = "application/json"
}
~~~



- Acessar o diretório dos arquivos relacionados ao S3 e iniciar o projeto.
- Aplicar os arquivos Terraform.
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3
terraform init
terraform validate

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$ terraform init

Initializing the backend...

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding hashicorp/aws versions matching "3.23.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/random v3.1.2...
- Installed hashicorp/random v3.1.2 (signed by HashiCorp)
- Installing hashicorp/aws v3.23.0...
- Installed hashicorp/aws v3.23.0 (signed by HashiCorp)

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$
~~~


- Ao executar o Validate, foram encontrados erros:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$ terraform validate
╷
│ Error: Reference to undeclared input variable
│
│   on data.tf line 7, in data "terraform_remote_state" "server":
│    7:     region  = var.aws_region
│
│ An input variable with the name "aws_region" has not been declared. This variable can be declared with a variable "aws_region" {} block.
╵
╷
│ Error: Reference to undeclared input variable
│
│   on data.tf line 8, in data "terraform_remote_state" "server":
│    8:     profile = var.aws_profile
│
│ An input variable with the name "aws_profile" has not been declared. This variable can be declared with a variable "aws_profile" {} block.
╵
╷
│ Error: Reference to undeclared input variable
│
│   on main.tf line 13, in provider "aws":
│   13:   region  = var.aws_region
│
│ An input variable with the name "aws_region" has not been declared. This variable can be declared with a variable "aws_region" {} block.
╵
╷
│ Error: Reference to undeclared input variable
│
│   on main.tf line 14, in provider "aws":
│   14:   profile = var.aws_profile
│
│ An input variable with the name "aws_profile" has not been declared. This variable can be declared with a variable "aws_profile" {} block.
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$
~~~


- Estava faltando a criação do arquivo variables.tf na pasta do S3:

~~~hcl
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
~~~


- Após a criação o Validate ficou ok:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$
~~~



- Efetuando plan e apply:
terraform plan
terraform apply -auto-approve

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.this will be created
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
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "application/json"
      + etag                   = "78d8e8e8c3fb2ebb5eed70968da17eb7"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "instances/instances-ami-015cfeb4e0d6306b2.json"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "outputs.json"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + server = {
      + ami = "ami-015cfeb4e0d6306b2"
      + arn = "arn:aws:ec2:us-east-1:816678621138:instance/i-0826ad3d798627604"
      + id  = "i-0826ad3d798627604"
    }
random_pet.this: Creating...
random_pet.this: Creation complete after 0s [id=gratefully-utterly-suddenly-peaceful-trout]
aws_s3_bucket.this: Creating...
aws_s3_bucket.this: Still creating... [10s elapsed]
aws_s3_bucket.this: Creation complete after 10s [id=my-bucket-gratefully-utterly-suddenly-peaceful-trout]
aws_s3_bucket_object.this: Creating...
aws_s3_bucket_object.this: Creation complete after 2s [id=instances/instances-ami-015cfeb4e0d6306b2.json]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

server = {
  "ami" = "ami-015cfeb4e0d6306b2"
  "arn" = "arn:aws:ec2:us-east-1:816678621138:instance/i-0826ad3d798627604"
  "id" = "i-0826ad3d798627604"
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula19-Data-sources/s3$
~~~



- Aplicado com sucesso, Bucket criado.
- Outputs obtidos do nosso Data Source "terraform_remote_state" foram trazidos com sucesso.
- Lembrando que a sintaxe para pegar um dado especifico é:
arn = data.terraform_remote_state.<nome-do-recurso>.<nome-da-parte-do-recurso>.<nome-da-informação-que-queremos>
arn = data.terraform_remote_state.server.outputs.arn



