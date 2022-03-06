


# aula 14. Interpolação, locals e outputs


- Primeiro vamos criar nosso main.tf, s3.tf e o variables.tf:

- Arquivo main.tf

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
  region  = var.aws_region
  profile = var.aws_profile
}
~~~

-Arquivo s3.tf

~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "meu-super-bucket"

  tags = {
    Name        = "Meu Super Bucket"
    Environment = var.environment
    Managedby   = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt   = "06-02-2022"
    Project     = "Curso do Cleber"
  }
}
~~~


- Arquivo variables.tf

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

variable "environment" {
  type        = string
  description = ""
  default     = "dev"
}
~~~




- Interpolação

A interpolação é usada no Terraform com a sintaxe ${}, por exemplo:
    ${var.foo}

Permite referenciar variáveis, atributos de recursos, chamar funções, etc.
É usada para concatenar expressões em strings.
Pode ser usada a interpolação em tarefas mais complexas, como expressões matemáticas, condicionais para determinar valores com alguma lógica.


- Escapando uma interpolação
Usando:
$${foo}
Será entendido como ${foo} literalmente.
You can escape interpolation with double dollar signs: $${foo} will be rendered as a literal ${foo}.




- Interpolation

A ${ ... } sequence is an interpolation, which evaluates the expression given between the markers, converts the result to a string if necessary, and then inserts it into the final string:

    "Hello, ${var.name}!"

In the above example, the named object var.name is accessed and its value inserted into the string, producing a result like "Hello, Juan!".





# Provider Random

- Usar o provider Random e o seu recurso Random Pet:
    https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
- Este recurso auxilia na criação de nomes únicos para os recursos. Ele gera nomes aleatórios de Pet, para serem usados como identificadores únicos.
    The resource random_pet generates random pet names that are intended to be used as unique identifiers for other resources.

- Example Usage

~~~hcl
# The following example shows how to generate a unique pet name
# for an AWS EC2 instance that changes each time a new AMI id is
# selected.

resource "random_pet" "server" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    ami_id = "${var.ami_id}"
  }
}

resource "aws_instance" "server" {
  tags = {
    Name = "web-server-${random_pet.server.id}"
  }

  # Read the AMI id "through" the random_pet resource to ensure that
  # both will change together.
  ami = random_pet.server.keepers.ami_id

  # ... (other aws_instance arguments) ...
}
~~~



- No nosso caso, iremos usar o Schema length, para definir o tamanho do nome gerado.
- Criar um arquivo chamado random.tf no nosso diretório do projeto:

aulas/aula14-Interpolacao-locals-e-outputs/random.tf

~~~hcl
resource "random_pet" "bucket" {
    length = 5
}
~~~




- Trocar o nome do nosso bucket, usando o recurso de random_pet do Provider Random.
- Editar o arquivo s3.tf
- Utilizar o nome aleatório para o bucket, chamando random_pet.bucket.id e concatenar o contexto do ambiente dev, usando a variável var.environment.

DE:
~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "meu-super-bucket"
~~~

PARA:
~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"
~~~


- Executar o terraform init, para iniciar os providers e começar a trabalhar com o Terraform.
- Note que ele baixou e instalou o Random desta vez.

~~~bash
terraform init
~~~

Initializing provider plugins...
- Finding hashicorp/aws versions matching "4.2.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/aws v4.2.0...
- Installed hashicorp/aws v4.2.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)


- Necessário ir no nosso arquivo main.tf e fixar a versão do nosso provider Random.
- Podemos ver a versão do Random pela saída do terraform init ou através do arquivo [aulas/aula14-Interpolacao-locals-e-outputs/.terraform.lock.hcl].
- Novo arquivo main.tf:
~~~hcl
terraform {
  required_version = "1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
~~~





- Necessário executar o terraform plan para verificar o que será criado.
- Executando o terraform plan jogando a saída para um arquivo out.
~~~bash
terraform plan -out="tfplan.out"
~~~

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$ terraform plan -out="tfplan.out"
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.super-bucket will be created
  + resource "aws_s3_bucket" "super-bucket" {
[...]
      + bucket                               = (known after apply)
      + bucket_domain_name                   = (known after apply)
[...]
      + tags                                 = {
          + "Environment" = "dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "Meu Super Bucket"
          + "Owner"       = "Fernando Müller"
          + "Project"     = "Curso do Cleber"
          + "UpdatedAt"   = "06-02-2022"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "Managedby"   = "Terraform"
          + "Name"        = "Meu Super Bucket"
          + "Owner"       = "Fernando Müller"
          + "Project"     = "Curso do Cleber"
          + "UpdatedAt"   = "06-02-2022"
        }
        [...]
  # random_pet.bucket will be created
  + resource "random_pet" "bucket" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan.out"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$
~~~


- Observação
o nome do bucket veio com a informação de (known after apply), pois ele será nomeado somente depois que o recurso random_pet ser criado.
 + bucket                               = (known after apply)






- Criando os recursos com o nosso arquivo out que foi criado anteriormente:

terraform apply "tfplan.out"

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$ terraform apply "tfplan.out"
random_pet.bucket: Creating...
random_pet.bucket: Creation complete after 0s [id=normally-overly-evidently-great-platypus]
aws_s3_bucket.super-bucket: Creating...
aws_s3_bucket.super-bucket: Creation complete after 4s [id=normally-overly-evidently-great-platypus-dev]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$

- Detalhando a saída:
1 - Criou o recurso [random_pet.bucket] chamado [normally-overly-evidently-great-platypus].
2 - Criou o recurso [aws_s3_bucket.super-bucket] chamado [id=normally-overly-evidently-great-platypus-dev], já concatenando o valor do nosso ambiente dev.







# Local values

https://www.terraform.io/language/values/locals

As Local Values são usadas quando existem valores que serão repetidos muitas vezes numa configuração, daí podem ser definidos uma vez e depois basta editar o local deste
valor num local centralizado, facilitando o ajuste num futuro.
O Local auxilia nos casos dos valores ou expressões repetidos muitas vezes, mas deve ser usado com cuidado, pois dependendo do uso pode dificultar uma manutenção
do código no futuro.


- Declaring a Local Value

A set of related local values can be declared together in a single locals block:
~~~hcl
locals {
  service_name = "forum"
  owner        = "Community Team"
}
~~~

The expressions in local values are not limited to literal constants; they can also reference other values in the module in order to transform or combine them, including variables, resource attributes, or other local values:
~~~hcl
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
~~~



- Criar um arquivo chamado locals.tf
- Editar ele.
- Vamos pegar as tags do arquivo s3.tf e usar no locals.tf, para criar uma local chamada "common_tags" com as variáveis.


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$ terraform fmt
locals.tf
random.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$

~~~hcl
locals {
  common_tags = {
    Name        = "Meu Super Bucket"
    Environment = var.environment
    Managedby   = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt   = "06-02-2022"
    Project     = "Curso do Cleber"
  }
}
~~~



- Observação:
ao definir os locals, usamos a palavra no plural.
ao utilizar a local, usamos a palavra no singular.


- No arquivo s3.tf, trocando as tags pela local que criamos, fica assim:
~~~hcl
resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"

  tags = local.common_tags
}
~~~



- Criar um arquivo json com alguns endereços ip ficticios para uso no arquivo s3.tf

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs/ips.json
~~~

~~~json
{
  "public": ["127.0.0.0", "127.0.0.1", "127.0.0.2"],
  "private": ["255.255.255.0", "13.324.324.22"]
}
~~~







# Resource: aws_s3_bucket_object

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object

- Example Usage
- Uploading a file to a bucket
~~~hcl
resource "aws_s3_bucket_object" "object" {
  bucket = "your_bucket_name"
  key    = "new_object_key"
  source = "path/to/file"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("path/to/file")
}
~~~

- Nosso recurso de upload do objeto para o bucket do S3 vai ficar assim:
~~~hcl
resource "aws_s3_bucket_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/ips.json"
    source = "ips.json"
    etag = filemd5("ips.json")
}
~~~

- Explicando detalhadamente o que faz cada parte do código:

        o bucket define o bucket onde vai ser feito o upload do objeto, o nome do Bucket é acessado usando a sintaxe:
            aws_s3_bucket.[nome-do-bucket].bucket

        a key é o nome do objeto, quando ele estiver no bucket do S3.

        o source é o arquivo que iremos enviar.

        a etag monitora o arquivo, efetuando um upload da nova versão dele, caso o arquivo seja alterado.
            etag - (Optional) Triggers updates when the value changes. The only meaningful value is filemd5("path/to/file")



- Importante.
- É possível verificar que no recurso que estamos criando o nome "ips.json" se repete 3x. Sendo um bom indicativo de uso deste valor num local.
- Editar o arquivo locals.tf e incluir o local 
~~~hcl
locals {
    
    ip_filepath = "ips.json"
    common_tags = {
        Name        = "Meu Super Bucket"
        Environment = var.environment
        Managedby   = "Terraform"
        Owner       = "Fernando Müller"
        UpdatedAt   = "06-02-2022"
        Project     = "Curso do Cleber"
        }
}
~~~


- Editando o arquivo s3.tf, vamos referenciar a local criada no locals.tf
- Trocando os valores do arquivo json em 3 lugares.
- Observação, no valor da key é necessário informar o local entre chaves.
~~~hcl
resource "aws_s3_bucket_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${local.ip_filepath}"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
}
~~~







-


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$ terraform apply "tfplan.out"

random_pet.bucket: Creating...
random_pet.bucket: Creation complete after 0s [id=normally-overly-evidently-great-platypus]
aws_s3_bucket.super-bucket: Creating...
aws_s3_bucket.super-bucket: Creation complete after 4s [id=normally-overly-evidently-great-platypus-dev]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

aws_s3_bucket.super-bucket: Destroying... [id=normally-overly-evidently-great-platypus-dev]
aws_s3_bucket.super-bucket: Destruction complete after 1s
random_pet.bucket: Destroying... [id=normally-overly-evidently-great-platypus]
random_pet.bucket: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula14-Interpolacao-locals-e-outputs$


- Continua em 10:40h do video.