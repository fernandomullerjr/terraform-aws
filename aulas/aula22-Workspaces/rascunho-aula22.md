

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

~~~~bash
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
~~~~




# pendente
- Continua em 12min
- Ver questões sobre deletar o workspace, DynamoDB, Destroy, Lock, S3, 
- Ver diferença entre Workspace da Cloud e esse.

~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket





# Dia 26/06/2022

- Um registro é criado a cada Workspace que é criado no Terraform, esse registro é um item no DynamoDB. Ele contem um LockID.


- Alternando para o Workspace dev e efetuando plan para ver quantos recursos vão ser criados:

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
  dev
* prod

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace select dev
Switched to workspace "dev".
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
* dev
  prod

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace delete prod
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
Deleted workspace "prod"!
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform plan
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web[0] will be created
  + resource "aws_instance" "web" {
      + ami                          = "ami-08d4ac5b634553e16"
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
[.................]
      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
~~~~




terraform apply --auto-approve


- Durante o Apply no Workspace, é gerado um item na tabela do DynamoDB, refernete a ação do Apply, contendo detalhes como o ID da operação, nome da operação, quem aplicou, versão do Terraform, data da criação e o path do Terraform State do Workspace em questão:

arquivo de lock
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces/lock.json

~~~~json
{
    "ID": "b586746f-77bf-95c7-2917-7f8aa5c7ccf8",
    "Operation": "OperationTypeApply",
    "Info": "",
    "Who": "fernando@debian10x64",
    "Version": "1.1.5",
    "Created": "2022-06-26T15:14:26.155851479Z",
    "Path": "tfstate-816678621138/env:/dev/05-workspaces/terraform.tfstate"
}
~~~~




- Criada 1 máquina na região da Virginia, devido estar no Workspace de dev:

~~~~bash
Plan: 1 to add, 0 to change, 0 to destroy.
aws_instance.web[0]: Creating...
aws_instance.web[0]: Still creating... [10s elapsed]
aws_instance.web[0]: Still creating... [20s elapsed]
aws_instance.web[0]: Still creating... [30s elapsed]
aws_instance.web[0]: Still creating... [40s elapsed]
aws_instance.web[0]: Creation complete after 40s [id=i-0d7a9a678349b17cb]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~




- Criando mais um workspace.

terraform workspace new stage

- Verificando no bucket do S3, já existe a pasta para o novo Workspace chamado "stage".

- Não é possível deletar um Workspace, quando se está usando ele:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace new stage
Created and switched to workspace "stage"!

You re now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
  dev
* stage

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace delete stage
Workspace "stage" is your active workspace.

You cannot delete the currently active workspace. Please switch
to another workspace and try again.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~





- Alternando novamente para o Workspace "dev", para poder deletar o Workspace "stage"
terraform workspace select dev


- Comando para deletar o Workspace "stage"
terraform workspace delete stage

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace select dev
Switched to workspace "dev".
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace delete stage
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
Deleted workspace "stage"!
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~


Verificando no Bucket do S3, entradas referentes ao Workspace "stage" foram deletadas também.






- Efetuando a limpeza geral.
- Destroy dos recursos criados via Workspace "dev".
- Remoção dos Workspaces.
- Conferindo bucket do S3 e DynamoDB.
- Validando terminate das EC2.
-


terraform destroy --auto-approve
terraform destroy --auto-approve
terraform workspace list
terraform workspace select default
terraform workspace delete dev
terraform workspace list


~~~~bash
Plan: 0 to add, 0 to change, 1 to destroy.
aws_instance.web[0]: Destroying... [id=i-0d7a9a678349b17cb]
aws_instance.web[0]: Still destroying... [id=i-0d7a9a678349b17cb, 10s elapsed]
aws_instance.web[0]: Still destroying... [id=i-0d7a9a678349b17cb, 20s elapsed]
aws_instance.web[0]: Still destroying... [id=i-0d7a9a678349b17cb, 30s elapsed]
aws_instance.web[0]: Destruction complete after 33s
Releasing state lock. This may take a few moments...

Destroy complete! Resources: 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
  default
* dev

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace select default
Switched to workspace "default".
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace delete dev
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
Deleted workspace "dev"!
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$ terraform workspace list
* default

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula22-Workspaces$
~~~~