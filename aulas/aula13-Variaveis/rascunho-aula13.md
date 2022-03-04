

# Aula 13. Variáveis


- Acessar o site do Terraform e ir em AWS Resource, procurar por "aws_instance"

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

- Pegar um exemplo de "aws_instance".
- No exemplo abaixo ele já busca o AMI automaticamente.

- Basic Example Using AMI Lookup:

~~~hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
~~~



- Exemplos pegando o AMI de outras distribuições de forma automatizada:
    https://letslearndevops.com/2018/08/23/terraform-get-latest-centos-ami/

- Localizador de AMI do Ubuntu:
    https://cloud-images.ubuntu.com/locator/ec2/



- Pegando o código da AMI na Amazon, para uma máquina Amazon Linux 2:
    Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type - ami-0c293f3f676ec4f90 (64-bit x86)

- Código da máquina Ubuntu:
    Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-04505e74c0741db8d (64-bit x86) /

- Inicialmente vamos usar o trecho do código da "aws_instance", onde a AMI não é obtida dinamicamente.
- Vamos botar o id da ami no lugar do data source do ubuntu id.

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis/main.tf
~~~

~~~hcl
resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
~~~


- Criar um arquivo para as variáveis, chamado variable.tf e criar todas as variáveis usadas.
- Sendo uma para a região, uma para a ami, uma para o tipo de instância e uma do tipo map com as tags.

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis/variables.tf
~~~

~~~hcl
variable "aws_region" {
    type = string
    description = "value"
    default = "us-east-1"
}

variable "instance_ami" {
    type = string
    description = "value"
    default = "ami-04505e74c0741db8d"
}

variable "instance_type" {
    type = string
    description = "value"
    default = "t3.micro"
}

variable "instance_tags" {
  type        = map(string)
  description = "value"
  default = {
    Name    = "Ubuntu"
    Project = "Curso AWS com Terraform"
  }
}
~~~



# Ajustar o arquivo main.tf

- Colocar variáveis no lugar dos valores preenchidos manualmente.
- A sintaxe da variável é:
    var.nome_da_variavel

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis/main.tf
~~~

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
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = var.instance_tags
}
~~~



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform fmt
variables.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$


terraform init


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v4.2.0...
- Installed hashicorp/aws v4.2.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$





terraform plan

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-04505e74c0741db8d"
       [...]
      + instance_type                        = "t3.micro"
        [...]
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name"    = "Ubuntu"
          + "Project" = "Curso AWS com Terraform"
        }
      + tags_all                             = {
          + "Name"    = "Ubuntu"
          + "Project" = "Curso AWS com Terraform"
        }
      + tenancy                              = (known after apply)

Plan: 1 to add, 0 to change, 0 to destroy.





-ERRO ao tentar executar o "terraform apply -auto-approve":


Plan: 1 to add, 0 to change, 0 to destroy.
aws_instance.web: Creating...
╷
│ Error: Error launching source instance: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message: NVPRSVNm3z2dx36to2WaX2KVcFRBTBVV8haYjg1rxaCL4m0NUrpzZ8AmseRdtzLXV6Vw2j7ShJ1q5Tb9cIjp2Y63y9_-REXIDLRsOiQOswxIzyFiyzgzpgbRdv2pHk4A
│       status code: 403, request id: f17afd29-ea43-403c-af9c-a1cd2760aa19
│
│   with aws_instance.web,
│   on main.tf line 15, in resource "aws_instance" "web":
│   15: resource "aws_instance" "web" {
│
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ aws s3 ls

An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied


- SOLUÇÃO

Cadastrar outro par de chave da AWS nas credentials da AWS.
Definir o profile a configuração do main.tf, usando a variável var.aws_profile.

- Novo variables.tf:

~~~hcl
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_ami" {
  type        = string
  description = "Ubuntu 20 - ami"
  default     = "ami-04505e74c0741db8d"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
  default     = "fernandomuller"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags"
  default = {
    Name    = "Ubuntu"
    Project = "Curso AWS com Terraform"
  }
}
~~~


- Executando novamente o apply, após ajuste da profile:

~~~bash
terraform apply -auto-approve

Plan: 1 to add, 0 to change, 0 to destroy.
aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Creation complete after 15s [id=i-02d361013403e23cf]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~



- Removendo o valor default da variável, ao tentar executar o plan, o Terraform vai pedir para ser preenchido o valor.
- Este valor pode ser preenchido dinamicamente e alterado numa esteira de CI, por exemplo.

-Removendo o valor default da variável aws_profile:

~~~hcl
variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}
~~~

- Executando novo terraform plan, para testar, ele pede um valor:

terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan
var.aws_profile
  AWS Profile

  Enter a value:


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan
var.aws_profile
  AWS Profile

  Enter a value: fernandomuller

aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~




- É possível passar a variável ao Terraform no seguinte formato:

TF_VAR_aws_profile=fernandomuller terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ TF_VAR_aws_profile=fernandomuller terraform plan
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~

Ele consegue utilizar a variável como se tivesse sido informado no arquivo hcl.





- Também é possível passar a variável ao Terraform no seguinte formato:

terraform plan -var="aws_profile=fernandomuller"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan -var="aws_profile=fernandomuller"
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~



- Também é possível passar mais de 1 variável ao Terraform no seguinte formato:
- Observação: este formato sobrescreve a variável que definimos no variables.tf
- Neste exemplo vamos colocar um tipo de instancia mais forte(medium).

terraform plan -var="aws_profile=fernandomuller" -var="instance_type=t3.medium"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan -var="aws_profile=fernandomuller" -var="instance_type=t3.medium"
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-02d361013403e23cf"
      ~ instance_type                        = "t3.micro" -> "t3.medium"
    [...]

Plan: 0 to add, 1 to change, 0 to destroy.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~




- Passando a variável outra vez no mesmo comando, o próximo valor sobrescreve o valor anterior:

terraform plan -var="aws_profile=fernandomuller" -var="instance_type=t3.medium" -var="instance_type=t3.large"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan -var="aws_profile=fernandomuller" -var="instance_type=t3.medium" -var="instance_type=t3.large"
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-02d361013403e23cf"
      ~ instance_type                        = "t3.micro" -> "t3.large"
        [...]

Plan: 0 to add, 1 to change, 0 to destroy.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~





- Outra maneira de criar variáveis para utilização no Terraform é usando o arquivo terraform.tfvars

- Remover os valores das variáveis do arquivo variables.tf:

DE:

~~~hcl
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_ami" {
  type        = string
  description = "Ubuntu 20 - ami"
  default     = "ami-04505e74c0741db8d"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags"
  default = {
    Name    = "Ubuntu"
    Project = "Curso AWS com Terraform"
  }
}
~~~


PARA:

~~~hcl
variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "instance_ami" {
  type        = string
  description = "Ubuntu 20 - ami"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags"
  default = {
    Name    = "Ubuntu"
    Project = "Curso AWS com Terraform"
  }
}
~~~



- Arquivo terraform.tfvars

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis/terraform.tfvars
~~~

~~~hcl
aws_region = "us-east-1"

aws_profile = "fernandomuller"

instance_ami = "ami-04505e74c0741db8d"

instance_type = "t3.micro"
~~~





 terraform fmt

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform fmt
main.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$


- Como as nossas variáveis foram declaradas no arquivo terraform.tfvars, o Terraform faz a leitura dele automaticamente:

~~~hcl
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$
~~~




- Adicionar em variables.tf:

variable "environment" {
  type        = string
  description = ""
}


- Criar um arquivo chamado "dev.auto.tfvars", nele podemos colocar variáveis também, que o Terraform vai ler automaticamente também:

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis/dev.auto.tfvars
~~~

dentro dele, colocar:
environment = "dev"




terraform plan -var-file="prod.tfvars"

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform fmt
prod.tfvars
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$

terraform plan -var-file="prod.tfvars"

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform plan -var-file="prod.tfvars"
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-02d361013403e23cf"
      ~ instance_type                        = "t3.micro" -> "t3.medium"
      ~ tags                                 = {
          + "Env"     = "Prod"
            # (2 unchanged elements hidden)
        }
      ~ tags_all                             = {
          + "Env"     = "Prod"
            # (2 unchanged elements hidden)
        }
        [...]
Plan: 0 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$




- Precedencia das variáveis no Terraform:

https://www.terraform.io/language/values/variables
Variable Definition Precedence

Terraform loads variables in the following order, with later sources taking precedence over earlier ones:

    Environment variables
    The terraform.tfvars file, if present.
    The terraform.tfvars.json file, if present.
    Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
    Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)



terraform apply -var-file="prod.tfvars" -auto-approve


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform apply -var-file="prod.tfvars" -auto-approve
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-02d361013403e23cf"
      ~ instance_type                        = "t3.micro" -> "t3.medium"
      ~ tags                                 = {
          + "Env"     = "Prod"
            # (2 unchanged elements hidden)
        }
      ~ tags_all                             = {
          + "Env"     = "Prod"
            # (2 unchanged elements hidden)
        }
        [...]
Plan: 0 to add, 1 to change, 0 to destroy.
aws_instance.web: Modifying... [id=i-02d361013403e23cf]
aws_instance.web: Still modifying... [id=i-02d361013403e23cf, 10s elapsed]
aws_instance.web: Still modifying... [id=i-02d361013403e23cf, 1m0s elapsed]
aws_instance.web: Still modifying... [id=i-02d361013403e23cf, 1m10s elapsed]
aws_instance.web: Still modifying... [id=i-02d361013403e23cf, 1m20s elapsed]
aws_instance.web: Modifications complete after 1m26s [id=i-02d361013403e23cf]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$





- Efetuando o destroy do recurso:

terraform destroy -var-file="prod.tfvars" -auto-approve


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$ terraform destroy -var-file="prod.tfvars" -auto-approve
aws_instance.web: Refreshing state... [id=i-02d361013403e23cf]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web will be destroyed
  - resource "aws_instance" "web" {

aws_instance.web: Still destroying... [id=i-02d361013403e23cf, 1m10s elapsed]
aws_instance.web: Destruction complete after 1m12s

Destroy complete! Resources: 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula13-Variaveis$



- Observação: a sintaxe do var-file e do -auto-approve é a mesma para os comandos plan, apply e destroy.