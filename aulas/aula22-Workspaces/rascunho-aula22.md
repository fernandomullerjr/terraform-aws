

# WORKSPACES


- Vamos pegar o projeto de Remote State no S3, onde tem a parte sobre DynamoDB, vamos aplicar ele e pegar o LOCK da Tabela do Dynamo:


/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket/main.tf






- Criando arquivo main.tf


~~~~h
terraform {
  required_version = "0.14.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-968339500772"
    key            = "05-workspaces/terraform.tfstate"
    region         = "eu-central-1"
    profile        = "tf014"
    dynamodb_table = "tflock-tfstate-968339500772"
  }
}

provider "aws" {
  region  = lookup(var.aws_region, local.env)
  profile = "tf014"
}

locals {
  env = terraform.workspace == "default" ? "dev" : terraform.workspace
}

resource "aws_instance" "web" {
  count = lookup(var.instance, local.env)["number"]

  ami           = lookup(var.instance, local.env)["ami"]
  instance_type = lookup(var.instance, local.env)["type"]

  tags = {
    Name = "Minha máquina web ${local.env}"
    Env  = local.env
  }
}
~~~~




- Criando arquivo variables.tf

~~~~h
variable "aws_region" {
  description = "AWS region where the resources will be created"

  type = object({
    dev  = string
    prod = string
  })

  default = {
    dev  = "eu-central-1"
    prod = "us-east-1"
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
      ami    = "ami-0233214e13e500f77"
      type   = "t3.micro"
      number = 1
    }
    prod = {
      ami    = "ami-0ff8a91507f77f867"
      type   = "t3.medium"
      number = 3
    }
  }
}
~~~~





# IMPORTANTE
# Explicação sobre o Locals

~~~~h
locals {
  env = terraform.workspace == "default" ? "dev" : terraform.workspace
}
~~~~

- Se o valor for igual a "default", setar o valor "dev" para a palavra reservada terraform.workspace, pois não podemos ter um Workspace chamado Default.





- Comandos

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace -h
Usage: terraform [global options] workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~




- Ajustando
profile
region
tf-state


fernandomuller

    dev  = "us-east-1"
    prod = "us-east-2"



  backend "s3" {
    bucket         = "tfstate-816678621138"
    dynamodb_table = "tflock-tfstate-816678621138"



- Verificando o Workspace atual:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace show
default
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~



- Efetuando INIT:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ rm -rf .terraform/
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform init

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.23.0"...
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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~


- Verificando os Workspaces existentes.
- Usar o comando:
    terraform workspace list

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
* default

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~



- Criando um workspace.
- Usar o comando:
    terraform workspace new dev
- Esse comando já efetua a criação e muda para o novo Workspace direto.

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace new dev
Created and switched to workspace "dev"!

You re now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
* dev

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~



- Após isto é criado o tfstate no diretório:
    Amazon S3
    Buckets
    tfstate-816678621138
    env:/
    dev/
    05-workspaces/


- Já no DynamoDB é criado um item.
DynamoDB
Items
tflock-tfstate-816678621138

Campo LockID
tfstate-816678621138/env:/dev/05-workspaces/terraform.tfstate-md5










fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
  dev
* prod

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$






- Simulando aplicação no Workspace de prod.
- Como as variaveis de prod criariam 3 maquinas, no terraform plan constam 3 to add.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform plan
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web[0] will be created
  + resource "aws_instance" "web" {
      + ami                          = "ami-0ff8a91507f77f867"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
[......]
Plan: 3 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────





- Continua em 12min