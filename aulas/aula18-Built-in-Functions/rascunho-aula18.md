



# Aula 18. Built-in functions

<https://www.terraform.io/language/functions>

- Assim como linguagens de programação, o Terraform tem funções embutidas.
- Elas podem ser chamadas e passados argumentos, assim como funções em programação.

- Nesta aula será criada uma EC2 e um bucket do S3.


# Funções

- Criando o arquivo variables.tf
- Arquivo de base:
    <https://raw.githubusercontent.com/chgasparoto/curso-aws-com-terraform/master/02-terraform-intermediario/02-builtin-functions/variables.tf>

- A função [length] traz a extensão da nossa variável:
~~~hcl
condition     = length(var.instance_ami) > 4 && substr(var.instance_ami, 0, 4) == "ami-"
~~~


- Função substr
<https://www.terraform.io/language/functions/substr>
substr extracts a substring from a given string by offset and length.
substr(string, offset, length)
offset = desvio, deslocamento, contrapartida
O offset e o length na função [substr] são os pontos de corte. Eles começam em 0, mas podem ter valores negativos também.
- A função [substr] tira uma parte da string, conforme os parametros informados.
- Neste caso ela vai pegar o que vier a partir de 0(começo da string), vai começar na posição 0 e vai tirar 4 caracteres.
- Os 4 caracteres removidos serão "ami-".
~~~hcl
condition     = length(var.instance_ami) > 4 && substr(var.instance_ami, 0, 4) == "ami-"
~~~

- Exemplos:
> substr("hello world", 1, 4)
ello
The offset and length are both counted in unicode characters rather than bytes:
> substr("🤔🤷", 0, 1)
🤔

- O índice de deslocamento pode ser negativo e, nesse caso, é relativo ao final da string fornecida. O comprimento pode ser -1, caso em que o restante da string após o deslocamento fornecido será retornado.
> substr("Olá mundo", -5, -1)
mundo



- Nosso bloco de validação fica assim:
~~~hcl
  validation {
    condition     = length(var.instance_ami) > 4 && substr(var.instance_ami, 0, 4) == "ami-"
    error_message = "The instance_ami value must be a valid AMI id, starting with \"ami-\"."
  }
~~~



- As funções do tipo object precisam de duas chaves com o valor number.
- No Default definimos os valores delas.

~~~hcl
variable "instance_number" {
  type = object({
    dev  = number
    prod = number
  })
  description = "Number of instances to create"
  default = {
    dev  = 1
    prod = 3
  }
}
~~~

~~~hcl
variable "instance_type" {
  type = object({
    dev  = string
    prod = string
  })
  description = ""
  default = {
    dev  = "t2.micro"
    prod = "t3.medium"
  }
}
~~~




- Verificando o estado atual

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform state list
data.aws_caller_identity.current
aws_dynamodb_table.lock-table
aws_s3_bucket.remote-state
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$
~~~



- Efetuando o destroy, ocorreram alguns erros:

~~~bash
Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - remote_state_bucket     = "tfstate-816678621138" -> null
  - remote_state_bucket_arn = "arn:aws:s3:::tfstate-816678621138" -> null
aws_dynamodb_table.lock-table: Destroying... [id=tflock-tfstate-816678621138]
aws_dynamodb_table.lock-table: Destruction complete after 2s
aws_s3_bucket.remote-state: Destroying... [id=tfstate-816678621138]
╷
│ Error: error deleting S3 Bucket (tfstate-816678621138): BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket.
│       status code: 409, request id: TKG69XNSFPWGD0RY, host id: tIEJR4tcgkzy66+4OCG0aZOihp5hDBFtufwqZgRjlvy0N8bers2t/gkjM5ImuOgwb2ctFr6rIKU=
│

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - remote_state_bucket     = "tfstate-816678621138" -> null
  - remote_state_bucket_arn = "arn:aws:s3:::tfstate-816678621138" -> null
aws_s3_bucket.remote-state: Destroying... [id=tfstate-816678621138]
╷
│ Error: error deleting S3 Bucket (tfstate-816678621138): BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket.
│       status code: 409, request id: BXY9HDB51WZGY2EC, host id: gCnIr3+UFBKvpY5sF9oIWyQUkyRkvBrWp/ASmMyk00r5lAqxbMhJFuYqIa1fv06fOgdt5GFpf/Y=
│
│

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform destroy -auto-approve
aws_s3_bucket.remote-state: Refreshing state... [id=tfstate-816678621138]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.remote-state will be destroyed
  - resource "aws_s3_bucket" "remote-state" {
      - acl                         = "private" -> null
      - arn                         = "arn:aws:s3:::tfstate-816678621138" -> null
      - bucket                      = "tfstate-816678621138" -> null
      - bucket_domain_name          = "tfstate-816678621138.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "tfstate-816678621138.s3.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3AQBSTGFYJSTF" -> null
      - id                          = "tfstate-816678621138" -> null
      - region                      = "us-east-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "CreatedAt"   = "2022-03-26"
          - "Description" = "Stores terraform remote state files"
          - "ManagedBy"   = "Terraform"
          - "Owner"       = "Fernando Muller Junior"
        } -> null

      - versioning {
          - enabled    = true -> null
          - mfa_delete = false -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - remote_state_bucket     = "tfstate-816678621138" -> null
  - remote_state_bucket_arn = "arn:aws:s3:::tfstate-816678621138" -> null
aws_s3_bucket.remote-state: Destroying... [id=tfstate-816678621138]
aws_s3_bucket.remote-state: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ ^C
~~~


- Foi necessário remover os objetos versionados, para poder seguir com o destroy do S3.







# Reforçar
- 
<https://www.terraform.io/language/functions/substr>

oPERATORS
<https://www.terraform.io/language/expressions/operators>

- Conditional Expressions
<https://www.terraform.io/language/expressions/conditionals>
The syntax of a conditional expression is as follows:
  condition ? true_val : false_val
If condition is true then the result is true_val. If condition is false then the result is false_val.

A common use of conditional expressions is to define defaults to replace invalid values:
  var.a != "" ? var.a : "default-a"
If var.a is an empty string then the result is "default-a", but otherwise it is the actual value of var.a.





- Criar arquivos [locals.tf]

~~~hcl
locals {
  instance_number = lookup(var.instance_number, var.env)

  file_ext    = "zip"
  object_name = "meu-arquivo-gerado-de-um-template"

  common_tags = {
    "Owner" = "Fernando Muller"
    "Year"  = "2022"
  }
}
~~~

- Criar arquivo [ec2.tf]

~~~hcl
resource "aws_instance" "server" {
  count = local.instance_number <= 0 ? 0 : local.instance_number

  ami           = var.instance_ami
  instance_type = lookup(var.instance_type, var.env)

  tags = merge(
    local.common_tags,
    {
      Project = "Curso AWS com Terraform"
      Env     = format("%s", var.env)
      Name    = format("Instance %d", count.index + 1)
    }
  )
}
~~~



- Count do EC2
- O Count no nosso caso vai controlar a quantidade de recursos que criamos deste tipo.
count = local.instance_number <= 0 ? 0 : local.instance_number

Se o número de instancias for menor ou igual a zero, o valor setado será 0.
Se o valor for maior que 0, ele vai setar o count com o valor que foi passado para a minha local instance_number.



- Função Lookup
<https://www.terraform.io/language/functions/lookup>
lookup retrieves the value of a single element from a map, given its key. If the given key does not exist, the given default value is returned instead.
  lookup(map, key, default)


- Exemplos:
Procura o valor de "a" no "map", como ele existe, retorna o valor da "key" fornecida.
> lookup({a=""ay"", b=""bee""}, ""a"", ""what?"")
ay"	

Procura o valor de "c" no "map", como não encontra, ele traz o valor "default".
> lookup({a=""ay"", b=""bee""}, ""c"", ""what?"")
what?"	


No nosso caso, o valor procurado é o valor da variável instance_number, valor na nossa variável de ambiente [env]:
~~~hcl
instance_number = lookup(var.instance_number, var.env)
~~~

Observação, cuidar a diferença entre o Locals [instance_number] e a Variável [instance_number], pode confundir um pouco.




- Função Merge
<https://www.terraform.io/language/functions/merge>
merge takes an arbitrary number of maps or objects, and returns a single map or object that contains a merged set of elements from all arguments.
If more than one given map or object defines the same key or attribute, then the one that is later in the argument sequence takes precedence. 
If the argument types do not match, the resulting type will be an object matching the type structure of the attributes after the merging rules have been applied.

- Exemplos:

> merge({a="b", c="d"}, {e="f", c="z"})
{
  "a" = "b"
  "c" = "z"
  "e" = "f"
}

> merge({a="b"}, {a=[1,2], c="z"}, {d=3})
{
  "a" = [
    1,
    2,
  ]
  "c" = "z"
  "d" = 3
}


- No nosso caso foi usado o Merge para unir a Local [local.common_tags], que tem as tags comuns, unindo as tags que são especificas desta EC2:

~~~hcl
  tags = merge(
    local.common_tags,
    {
      Project = "Curso AWS com Terraform"
      Env     = format("%s", var.env)
      Name    = format("Instance %d", count.index + 1)
    }
  )
~~~

- Observação:
  caso existam duas Keys com o mesmo atributo, a última fornecida terá precedência entre as demais.
  se os tipos de argumento não forem compativeis, o tipo resultante será um  tipo de objeto que seja compatível com os atributos, após as regras de merge serem aplicadas.

- Efetuando o Merge, ficaria algo assim as nossas Tags:

~~~hcl
  tags = {
      Project = "Curso AWS com Terraform"
      Env     = format("%s", var.env)
      Name    = format("Instance %d", count.index + 1)
      "Owner" = "Fernando Muller"
      "Year"  = "2022"
  }
~~~


- Função Format
<https://www.terraform.io/language/functions/format>
format produces a string by formatting a number of other values according to a specification string. It is similar to the printf function in C, and other similar functions in other programming languages.
  format(spec, values...)
- No nosso caso usamos o format para a Tag [env] e para a Tag [Name].
Env     = format("%s", var.env)
Name    = format("Instance %d", count.index + 1)

- No caso do [env], ele vai formatar o valor como String.
- No caso da Tag [Name], ele vai converter o valor para inteiro e produzir uma representaçaõ de decimal.

- Explicação da sintaxe e dos usos do simbolo de porcentagem, dos verbos:
  %s	Convert to string and insert the string's characters.
  %d	Convert to integer number and produce decimal representation.


- Exemplos:
Transforma o valor "Ander" em String e adiciona uma exclamação ao final da String.
> format("Hello, %s!", "Ander")
Hello, Ander!
> format("There are %d lights", 4)
There are 4 lights


- Simple format verbs like %s and %d behave similarly to template interpolation syntax, which is often more readable:
> format("Hello, %s!", var.name)
Hello, Valentina!
> "Hello, ${var.name}!"
Hello, Valentina!


- Usar a interpolação é mais fácil de ler, usando a função format fica complexo.




# Criando S3

- Usar o arquivo de referência:
  <https://github.com/chgasparoto/curso-aws-com-terraform/blob/master/02-terraform-intermediario/02-builtin-functions/s3.tf>

- Criar o arquivo [s3.tf]:

~~~hcl
resource "random_pet" "bucket" {
  length = 5
}

resource "aws_s3_bucket" "this" {
  bucket = "${random_pet.bucket.id}-${var.env}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_object" "this" {
  bucket       = aws_s3_bucket.this.bucket
  key          = "${uuid()}.${local.file_ext}"
  source       = data.archive_file.json.output_path
  etag         = filemd5(data.archive_file.json.output_path)
  content_type = "application/zip"

  tags = local.common_tags
}
~~~


- Novamente, está sendo usado o recurso random_pet para definir nomes aleatórios para alguns recursos.
- Para criar o objeto no Bucket, está sendo o usada uma featura do Terraform, que são os [Templates].


- Criar o arquivo chamado [data.tf]

~~~hcl
data "template_file" "json" {
  template = file("template.json.tpl")

  vars = {
    age    = 31
    eye    = "Brown"
    name   = "Fernando"
    gender = "Male"
  }
}

data "archive_file" "json" {
  type        = local.file_ext
  output_path = "${path.module}/files/${local.object_name}.${local.file_ext}"

  source {
    content  = data.template_file.json.rendered
    filename = "${local.object_name}.json"
  }
}
~~~


- No arquivo [data.tf] é possível verificar aonde está sendo gerado o Template.

- Criar um arquivo com os dados do Template:
aulas/aula18-Built-in-Functions/template.json.tpl
referência:
<https://github.com/chgasparoto/curso-aws-com-terraform/blob/master/02-terraform-intermediario/02-builtin-functions/template.json.tpl>


- No arquivo [data.tf], usamos o Data Source [template_file] para buscar as informações do Template num arquivo.
- template_file
<https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file>
The template_file data source renders a template from a template string, which is usually loaded from an external file.
Note
In Terraform 0.12 and later, the templatefile function offers a built-in mechanism for rendering a template from a file. Use that function instead, unless you are using Terraform 0.11 or earlier.

- No site do Terraform indica que o uso do Data Source [template_file] é antigo, atualmente existe uma função chamada [templatefile] que faz o mesmo trabalho.



-Example Usage

~~~hcl
data "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"
  vars = {
    consul_address = "${aws_instance.consul.private_ip}"
  }
}
~~~

Inside init.tpl you can include the value of consul_address. For example:
~~~bash
#!/bin/bash
echo "CONSUL_ADDRESS = ${consul_address}" > /tmp/iplist
~~~



- No arquivo do template é possível verificar aonde serão substituidas as variaveis informadas no arquivo data.
- Os valores são colocados como se fossem interpolações.
  "age": "${age}",
  "eyeColor": "${eye}",
  "name": "${name}",
  "gender": "${gender}",




# O Data Source [archive_file]

<https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file>

Generates an archive from content, a file, or directory of files.

- Example Usage

~~~hcl
# Archive a single file.

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/init.tpl"
  output_path = "${path.module}/files/init.zip"
}

# Archive multiple files and exclude file.

data "archive_file" "dotfiles" {
  type        = "zip"
  output_path = "${path.module}/files/dotfiles.zip"
  excludes    = [ "${path.module}/unwanted.zip" ]

  source {
    content  = "${data.template_file.vimrc.rendered}"
    filename = ".vimrc"
  }

  source {
    content  = "${data.template_file.ssh_config.rendered}"
    filename = ".ssh/config"
  }
}

# Archive a file to be used with Lambda using consistent file mode

data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_file      = "${path.module}/../lambda/my-function/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-my-function.js.zip"
}
~~~


- Nosso arquivo [data.tf]:

~~~hcl
data "template_file" "json" {
  template = file("template.json.tpl")

  vars = {
    age    = 31
    eye    = "Brown"
    name   = "Fernando"
    gender = "Male"
  }
}

data "archive_file" "json" {
  type        = local.file_ext
  output_path = "${path.module}/files/${local.object_name}.${local.file_ext}"

  source {
    content  = data.template_file.json.rendered
    filename = "${local.object_name}.json"
  }
}
~~~


- Temos as variáveis:
  file_ext    = "zip"
  object_name = "meu-arquivo-gerado-de-um-template"

- Path Module
o ${path.module} é uma palavra reservada do Terraform.
Ele traz o caminho da onde você está executando o seu terraform
<https://www.terraform.io/language/expressions/references>
  [path.module] is the filesystem path of the module where the expression is placed.


- Explicando o bloco "source" no código do data:
<https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file>
source - (Optional) Specifies attributes of a single source file to include into the archive.
The source block supports the following:
    content - (Required) Add this content to the archive with filename as the filename.
    filename - (Required) Set this as the filename when declaring a source.

- O "rendered" é o resultado renderizado do arquivo tpl, usando o Data Source "template_file" para criar ele:
<https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file>
rendered - The final rendered template.



- Criar arquivo para o S3.
- Arquivo será chamado [s3.tf]

~~~hcl
resource "random_pet" "bucket" {
  length = 5
}

resource "aws_s3_bucket" "this" {
  bucket = "${random_pet.bucket.id}-${var.env}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_object" "this" {
  bucket       = aws_s3_bucket.this.bucket
  key          = "${uuid()}.${local.file_ext}"
  source       = data.archive_file.json.output_path
  etag         = filemd5(data.archive_file.json.output_path)
  content_type = "application/zip"

  tags = local.common_tags
}
~~~



- É usada a função [uuid] do Terraform para gerar um valor aleatório.

uuid generates a unique identifier string.
The id is a generated and formatted as required by RFC 4122 section 4.4, producing a Version 4 UUID. The result is a UUID generated only from pseudo-random numbers.
This function produces a new value each time it is called, and so using it directly in resource arguments will result in spurious diffs. We do not recommend using the uuid function in resource configurations, but it can be used with care in conjunction with the ignore_changes lifecycle meta-argument.
In most cases we recommend using the random provider instead, since it allows the one-time generation of random values that are then retained in the Terraform state for use by future operations. In particular, random_id can generate results with equivalent randomness to the uuid function.
> uuid()
b5ee72a3-54dd-c4b8-551c-4bdc0204cedb


- No Source do objeto do S3, usamos o valor do "output_path", do nosso Data Source "archive_file", com nome "json":
  source       = data.archive_file.json.output_path



- Executando o projeto.
terraform fmt
terraform init
terraform plan
terraform apply


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform fmt
variables.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform init



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform plan
var.env
  Enter a value:



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform apply -auto-approve
var.env
  Enter a value:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform apply -auto-approve
var.env
  Enter a value: dev





╷
│ Error: Error launching source instance: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message: S4vUjgKaMZjh7c6q0Jf0NXE4YXMGLDo-1Q6YigpL2bkaLvu50IUmyYgHUiyzgaKhitZXrsqpwNq5wMO7SWxAqb-T9e_LpeONd8N1cxn28Yrc3XUjdXtCnIZpDv7ULLMqn6iGlNu3Ik-oKzQ1P5Y2bSzK3ZTqBu6kt2J28hpMlhnixopg36RPpzld0aYaspf9_1MJ32gv53XHeQMcnZFbrZNGUygReY8MYI24hqnxwUyQG9CQBuSSr6Ut-QYZfy9DrB-YYH9n9kc6R1_i7QSZrVZYy7VU8V-seKCo_crlc53vPPqrIqIj3joSmr4r1e4L87yYQbawr9EYlKV4SM4v4gbJgdUJfXLByqdOwm4lsolq8JvUAEP623RrdGsz6G_EOeATXGXNFezfuMUq8yRN7eHC58KdbB4oOIuLMGdyytjrUGlqKscANmflS_nQjiYZTgrL_5JM5C5wB5I2Fr6gLgX2v8B_Tnt-aRDdh7HueHNrFnHpvXhA0-tmtOaBMcbpBKvTQp5ua7_LP-9_P_KrxvCS5lXlIgHtZLBTI56-D5xXotplWF-F5gua-rOk__4OSqI4FOuCemCuevbEylaIU2J_BXfgbg9lQ1s81EM39gZwgEJBLE4iioOPp12qvcwRGrxYNQblg_w8S9W0SSULhDWrO1KrLElD3AI2tK6dDL_dmsOtAX7h8RtMAB3wuC6EwipVlAA6MBXi-1xZjprWK7kGDFCfl4vkawp6tF2HsITS6SWMSdC9w3lcrj6WoYVBg-S2tR2JKn63jBEj7nVjJv9HKdetZBS_owOcC4HjWCXuRxLQScOPkaQi_XrYywRp3hsCLTTJsneFtSr495V_in0nN4ZOfm9-w8-wy_63NFaLIiJpk8MLFbsvAIBW-TKg76xNnCUZQ8FlF82y_atiW4_ZDOBQvMpmikwiao3EsCkLSdcOsiSNf72Dt0dPS7kj3qtm9-9hvizdXNf7LFkI-oU9nPFDly4JPFhzKYbaJFNTYs5yXsYZt2c70ozV05Sev7geHstIaLi4xGIypUHckavJg1LH22HlhRR_57wIcUAYobzTo9RHJLhvbBX_at_YHqfu2IK--ShcLWUXXML1zzAPOMuynD1rsk_3kOe8PLzeSTLFbM7dl3TCW7PpXD_bKmYVXbekxU7Kg4ycitq-na3tBMSYahuz9dRHTjgxe7AKdq680vSHOHAN_2jwHZjkvJN4x_Cqsh-lBWFB6UbO2NEBQzaVVTa9Mrlo_mR_Icln76aW78iwkKWj2aCpd5XdrZ7btSoi7xyt2fVdiKGroT7ataAdrfjZN0yldqZUMBkWySZF8-3bVFsfEJiRTWH-HA
│       status code: 403, request id: 153422dc-c80b-48c6-bbfc-dac49aab0f86
│
│   with aws_instance.server[0],
│   on ec2.tf line 1, in resource "aws_instance" "server":
│    1: resource "aws_instance" "server" {
│
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$



- Conseguiu criar o Bucket no S3, só não criou a instancia EC2 mesmo.


https://aws.amazon.com/pt/premiumsupport/knowledge-center/ec2-not-auth-launch/

aws sts decode-authorization-message --encoded-message S4vUjgKaMZjh7c6q0Jf0NXE4YXMGLDo-1Q6YigpL2bkaLvu50IUmyYgHUiyzgaKhitZXrsqpwNq5wMO7SWxAqb-T9e_LpeONd8N1cxn28Yrc3XUjdXtCnIZpDv7ULLMqn6iGlNu3Ik-oKzQ1P5Y2bSzK3ZTqBu6kt2J28hpMlhnixopg36RPpzld0aYaspf9_1MJ32gv53XHeQMcnZFbrZNGUygReY8MYI24hqnxwUyQG9CQBuSSr6Ut-QYZfy9DrB-YYH9n9kc6R1_i7QSZrVZYy7VU8V-seKCo_crlc53vPPqrIqIj3joSmr4r1e4L87yYQbawr9EYlKV4SM4v4gbJgdUJfXLByqdOwm4lsolq8JvUAEP623RrdGsz6G_EOeATXGXNFezfuMUq8yRN7eHC58KdbB4oOIuLMGdyytjrUGlqKscANmflS_nQjiYZTgrL_5JM5C5wB5I2Fr6gLgX2v8B_Tnt-aRDdh7HueHNrFnHpvXhA0-tmtOaBMcbpBKvTQp5ua7_LP-9_P_KrxvCS5lXlIgHtZLBTI56-D5xXotplWF-F5gua-rOk__4OSqI4FOuCemCuevbEylaIU2J_BXfgbg9lQ1s81EM39gZwgEJBLE4iioOPp12qvcwRGrxYNQblg_w8S9W0SSULhDWrO1KrLElD3AI2tK6dDL_dmsOtAX7h8RtMAB3wuC6EwipVlAA6MBXi-1xZjprWK7kGDFCfl4vkawp6tF2HsITS6SWMSdC9w3lcrj6WoYVBg-S2tR2JKn63jBEj7nVjJv9HKdetZBS_owOcC4HjWCXuRxLQScOPkaQi_XrYywRp3hsCLTTJsneFtSr495V_in0nN4ZOfm9-w8-wy_63NFaLIiJpk8MLFbsvAIBW-TKg76xNnCUZQ8FlF82y_atiW4_ZDOBQvMpmikwiao3EsCkLSdcOsiSNf72Dt0dPS7kj3qtm9-9hvizdXNf7LFkI-oU9nPFDly4JPFhzKYbaJFNTYs5yXsYZt2c70ozV05Sev7geHstIaLi4xGIypUHckavJg1LH22HlhRR_57wIcUAYobzTo9RHJLhvbBX_at_YHqfu2IK--ShcLWUXXML1zzAPOMuynD1rsk_3kOe8PLzeSTLFbM7dl3TCW7PpXD_bKmYVXbekxU7Kg4ycitq-na3tBMSYahuz9dRHTjgxe7AKdq680vSHOHAN_2jwHZjkvJN4x_Cqsh-lBWFB6UbO2NEBQzaVVTa9Mrlo_mR_Icln76aW78iwkKWj2aCpd5XdrZ7btSoi7xyt2fVdiKGroT7ataAdrfjZN0yldqZUMBkWySZF8-3bVFsfEJiRTWH-HA



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ aws sts decode-authorization-message --encoded-message S4vUjgKaMZjh7c6q0Jf0NXE4YXMGLDo-1Q6YigpL2bkaLvu50IUmyYgHUiyzgaKhitZXrsqpwNq5wMO7SWxAqb-T9e_LpeONd8N1cxn28Yrc3XUjdXtCnIZpDv7ULLMqn6iGlNu3Ik-oKzQ1P5Y2bSzK3ZTqBu6kt2J28hpMlhnixopg36RPpzld0aYaspf9_1MJ32gv53XHeQMcnZFbrZNGUygReY8MYI24hqnxwUyQG9CQBuSSr6Ut-QYZfy9DrB-YYH9n9kc6R1_i7QSZrVZYy7VU8V-seKCo_crlc53vPPqrIqIj3joSmr4r1e4L87yYQbawr9EYlKV4SM4v4gbJgdUJfXLByqdOwm4lsolq8JvUAEP623RrdGsz6G_EOeATXGXNFezfuMUq8yRN7eHC58KdbB4oOIuLMGdyytjrUGlqKscANmflS_nQjiYZTgrL_5JM5C5wB5I2Fr6gLgX2v8B_Tnt-aRDdh7HueHNrFnHpvXhA0-tmtOaBMcbpBKvTQp5ua7_LP-9_P_KrxvCS5lXlIgHtZLBTI56-D5xXotplWF-F5gua-rOk__4OSqI4FOuCemCuevbEylaIU2J_BXfgbg9lQ1s81EM39gZwgEJBLE4iioOPp12qvcwRGrxYNQblg_w8S9W0SSULhDWrO1KrLElD3AI2tK6dDL_dmsOtAX7h8RtMAB3wuC6EwipVlAA6MBXi-1xZjprWK7kGDFCfl4vkawp6tF2HsITS6SWMSdC9w3lcrj6WoYVBg-S2tR2JKn63jBEj7nVjJv9HKdetZBS_owOcC4HjWCXuRxLQScOPkaQi_XrYywRp3hsCLTTJsneFtSr495V_in0nN4ZOfm9-w8-wy_63NFaLIiJpk8MLFbsvAIBW-TKg76xNnCUZQ8FlF82y_atiW4_ZDOBQvMpmikwiao3EsCkLSdcOsiSNf72Dt0dPS7kj3qtm9-9hvizdXNf7LFkI-oU9nPFDly4JPFhzKYbaJFNTYs5yXsYZt2c70ozV05Sev7geHstIaLi4xGIypUHckavJg1LH22HlhRR_57wIcUAYobzTo9RHJLhvbBX_at_YHqfu2IK--ShcLWUXXML1zzAPOMuynD1rsk_3kOe8PLzeSTLFbM7dl3TCW7PpXD_bKmYVXbekxU7Kg4ycitq-na3tBMSYahuz9dRHTjgxe7AKdq680vSHOHAN_2jwHZjkvJN4x_Cqsh-lBWFB6UbO2NEBQzaVVTa9Mrlo_mR_Icln76aW78iwkKWj2aCpd5XdrZ7btSoi7xyt2fVdiKGroT7ataAdrfjZN0yldqZUMBkWySZF8-3bVFsfEJiRTWH-HA
{
    "DecodedMessage": "{\"allowed\":false,\"explicitDeny\":true,\"matchedStatements\":{\"items\":[{\"statementId\":\"\",\"effect\":\"DENY\",\"principals\":{\"items\":[{\"value\":\"AIDA34JOWZ7JD6ORHXUBC\"}]},\"principalGroups\":{\"items\":[]},\"actions\":{\"items\":[{\"value\":\"ec2:RequestSpotInstances\"},{\"value\":\"ec2:RunInstances\"},{\"value\":\"ec2:StartInstances\"},{\"value\":\"iam:AddUserToGroup\"},{\"value\":\"iam:AttachGroupPolicy\"},{\"value\":\"iam:AttachRolePolicy\"},{\"value\":\"iam:AttachUserPolicy\"},{\"value\":\"iam:ChangePassword\"},{\"value\":\"iam:CreateAccessKey\"},{\"value\":\"iam:CreateInstanceProfile\"},{\"value\":\"iam:CreateLoginProfile\"},{\"value\":\"iam:CreatePolicyVersion\"},{\"value\":\"iam:CreateRole\"},{\"value\":\"iam:CreateUser\"},{\"value\":\"iam:DetachUserPolicy\"},{\"value\":\"iam:PassRole\"},{\"value\":\"iam:PutGroupPolicy\"},{\"value\":\"iam:PutRolePolicy\"},{\"value\":\"iam:PutUserPermissionsBoundary\"},{\"value\":\"iam:PutUserPolicy\"},{\"value\":\"iam:SetDefaultPolicyVersion\"},{\"value\":\"iam:UpdateAccessKey\"},{\"value\":\"iam:UpdateAccountPasswordPolicy\"},{\"value\":\"iam:UpdateAssumeRolePolicy\"},{\"value\":\"iam:UpdateLoginProfile\"},{\"value\":\"iam:UpdateUser\"},{\"value\":\"lambda:AddLayerVersionPermission\"},{\"value\":\"lambda:AddPermission\"},{\"value\":\"lambda:CreateFunction\"},{\"value\":\"lambda:GetPolicy\"},{\"value\":\"lambda:ListTags\"},{\"value\":\"lambda:PutProvisionedConcurrencyConfig\"},{\"value\":\"lambda:TagResource\"},{\"value\":\"lambda:UntagResource\"},{\"value\":\"lambda:UpdateFunctionCode\"},{\"value\":\"lightsail:Create*\"},{\"value\":\"lightsail:Delete*\"},{\"value\":\"lightsail:DownloadDefaultKeyPair\"},{\"value\":\"lightsail:GetInstanceAccessDetails\"},{\"value\":\"lightsail:Start*\"},{\"value\":\"lightsail:Update*\"},{\"value\":\"organizations:CreateAccount\"},{\"value\":\"organizations:CreateOrganization\"},{\"value\":\"organizations:InviteAccountToOrganization\"},{\"value\":\"s3:DeleteBucket\"},{\"value\":\"s3:DeleteObject\"},{\"value\":\"s3:DeleteObjectVersion\"},{\"value\":\"s3:PutLifecycleConfiguration\"},{\"value\":\"s3:PutBucketAcl\"},{\"value\":\"s3:PutBucketOwnershipControls\"},{\"value\":\"s3:DeleteBucketPolicy\"},{\"value\":\"s3:ObjectOwnerOverrideToBucketOwner\"},{\"value\":\"s3:PutAccountPublicAccessBlock\"},{\"value\":\"s3:PutBucketPolicy\"},{\"value\":\"s3:ListAllMyBuckets\"}]},\"resources\":{\"items\":[{\"value\":\"*\"}]},\"conditions\":{\"items\":[]}}]},\"failures\":{\"items\":[]},\"context\":{\"principal\":{\"id\":\"AIDA34JOWZ7JD6ORHXUBC\",\"name\":\"fernandomjunior\",\"arn\":\"arn:aws:iam::816678621138:user/fernandomjunior\"},\"action\":\"ec2:RunInstances\",\"resource\":\"arn:aws:ec2:us-east-1:816678621138:instance/*\",\"conditions\":{\"items\":[{\"key\":\"ec2:InstanceMarketType\",\"values\":{\"items\":[{\"value\":\"on-demand\"}]}},{\"key\":\"aws:Resource\",\"values\":{\"items\":[{\"value\":\"instance/*\"}]}},{\"key\":\"aws:Account\",\"values\":{\"items\":[{\"value\":\"816678621138\"}]}},{\"key\":\"ec2:AvailabilityZone\",\"values\":{\"items\":[{\"value\":\"us-east-1c\"}]}},{\"key\":\"ec2:ebsOptimized\",\"values\":{\"items\":[{\"value\":\"false\"}]}},{\"key\":\"ec2:IsLaunchTemplateResource\",\"values\":{\"items\":[{\"value\":\"false\"}]}},{\"key\":\"ec2:InstanceType\",\"values\":{\"items\":[{\"value\":\"t2.micro\"}]}},{\"key\":\"ec2:RootDeviceType\",\"values\":{\"items\":[{\"value\":\"ebs\"}]}},{\"key\":\"aws:Region\",\"values\":{\"items\":[{\"value\":\"us-east-1\"}]}},{\"key\":\"aws:Service\",\"values\":{\"items\":[{\"value\":\"ec2\"}]}},{\"key\":\"ec2:InstanceID\",\"values\":{\"items\":[{\"value\":\"*\"}]}},{\"key\":\"aws:Type\",\"values\":{\"items\":[{\"value\":\"instance\"}]}},{\"key\":\"ec2:Tenancy\",\"values\":{\"items\":[{\"value\":\"default\"}]}},{\"key\":\"ec2:Region\",\"values\":{\"items\":[{\"value\":\"us-east-1\"}]}},{\"key\":\"aws:ARN\",\"values\":{\"items\":[{\"value\":\"arn:aws:ec2:us-east-1:816678621138:instance/*\"}]}}]}}}"
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$




fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ aws s3 ls

An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$



fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ cat ~/.aws/credentials
[default]
aws_access_key_id = AKIA34JOWZ7JI3YJMTTK
aws_secret_access_key = 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

[fernando]
aws_access_key_id = AKIA34JOWZ7JI3YJMTTK
aws_secret_access_key = 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

[fernandomuller]
aws_access_key_id = AKIA34JOWZ7JEJTJSIOE
aws_secret_access_key = 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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$


export AWS_PROFILE=fernandomuller


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ export AWS_PROFILE=fernandomuller
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ aws s3 ls
2022-03-27 14:30:49 safely-arguably-legally-alert-lamb-dev
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$




terraform destroy -auto-approve
terraform apply -auto-approve



- Novos erros:


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform destroy -auto-approve
var.env
  Enter a value: dev

random_pet.bucket: Refreshing state... [id=safely-arguably-legally-alert-lamb]
╷
│ Warning: Argument is deprecated
│
│   with aws_s3_bucket_object.this,
│   on s3.tf line 11, in resource "aws_s3_bucket_object" "this":
│   11:   bucket       = aws_s3_bucket.this.bucket
│
│ Use the aws_s3_object resource instead
│
│ (and one more similar warning elsewhere)
╵
╷
│ Error: Invalid provider configuration
│
│ Provider "registry.terraform.io/hashicorp/aws" requires explicit configuration. Add a provider block to the root module and configure the provider's required arguments as described in the provider documentation.
│
╵
╷
│ Error: error configuring Terraform AWS Provider: error validating provider credentials: error calling sts:GetCallerIdentity: operation error STS: GetCallerIdentity, failed to resolve service endpoint, an AWS region is required, but was not found
│
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on <empty> line 0:
│   (source code not available)
│
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$



- Faltava o arquivo main.tf, criando ele:

~~~hcl
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "fernandomuller"
}
~~~




fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform destroy -auto-approve
var.env
  Enter a value: dev

╷
│ Error: Inconsistent dependency lock file
│
│ The following dependency selections recorded in the lock file are inconsistent with the current configuration:
│   - provider registry.terraform.io/hashicorp/archive: locked version selection 2.2.0 doesn't match the updated version constraints "2.0.0"
│   - provider registry.terraform.io/hashicorp/aws: locked version selection 4.8.0 doesn't match the updated version constraints "3.23.0"
│   - provider registry.terraform.io/hashicorp/random: locked version selection 3.1.2 doesn't match the updated version constraints "3.0.1"
│
│ To update the locked dependency selections to match a changed configuration, run:
│   terraform init -upgrade
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$




- Novo erro:


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform init -upgrade
╷
│ Error: Unsupported Terraform Core version
│
│   on main.tf line 2, in terraform:
│    2:   required_version = "0.14.4"
│
│ This configuration does not support Terraform version 1.1.5. To proceed, either choose another supported Terraform version or update this version constraint. Version constraints are normally set for good reason, so updating the
│ constraint may lead to other errors or unexpected behavior.
╵





- Ajustadas a versão do Terraform no arquivo [main.tf], a profile para [fernandomuller] e executado o init upgrade novamente:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform init -upgrade

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/template versions matching "2.2.0"...
- Finding hashicorp/aws versions matching "3.23.0"...
- Finding hashicorp/archive versions matching "2.0.0"...
- Finding hashicorp/random versions matching "3.0.1"...
- Using previously-installed hashicorp/template v2.2.0
- Installing hashicorp/aws v3.23.0...
- Installed hashicorp/aws v3.23.0 (signed by HashiCorp)
- Installing hashicorp/archive v2.0.0...
- Installed hashicorp/archive v2.0.0 (signed by HashiCorp)
- Installing hashicorp/random v3.0.1...
- Installed hashicorp/random v3.0.1 (signed by HashiCorp)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$


- Agora o Terraform baixou o Archive, Random e o Template.





terraform destroy -auto-approve
terraform apply -auto-approve


- ERRO:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform destroy -auto-approve
var.env
  Enter a value: dev

random_pet.bucket: Refreshing state... [id=safely-arguably-legally-alert-lamb]
╷
│ Error: error configuring Terraform AWS Provider: no valid credential sources for Terraform AWS Provider found.
│
│ Please see https://registry.terraform.io/providers/hashicorp/aws
│ for more information about providing credentials.
│
│ Error: NoCredentialProviders: no valid providers in chain. Deprecated.
│       For verbose messaging see aws.Config.CredentialsChainVerboseErrors
│
│
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on main.tf line 24, in provider "aws":
│   24: provider "aws" {
│
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$




- SOLUÇÃO
faltava salvar o arquivo main.tf, pois a profile havia sido modificada

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform destroy -auto-approve
var.env
  Enter a value: dev

random_pet.bucket: Refreshing state... [id=safely-arguably-legally-alert-lamb]
aws_s3_bucket.this: Refreshing state... [id=safely-arguably-legally-alert-lamb-dev]
aws_s3_bucket_object.this: Refreshing state... [id=32ec8b26-b36e-3338-b795-37966bc42095.zip]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.this will be destroyed
  - resource "aws_s3_bucket" "this" {
      - acl                         = "private" -> null
      - arn                         = "arn:aws:s3:::safely-arguably-legally-alert-lamb-dev" -> null
      - bucket                      = "safely-arguably-legally-alert-lamb-dev" -> null
      - bucket_domain_name          = "safely-arguably-legally-alert-lamb-dev.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "safely-arguably-legally-alert-lamb-dev.s3.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3AQBSTGFYJSTF" -> null
      - id                          = "safely-arguably-legally-alert-lamb-dev" -> null
      - region                      = "us-east-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Owner" = "Fernando Muller"
          - "Year"  = "2022"
        } -> null

      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }
    }

  # aws_s3_bucket_object.this will be destroyed
  - resource "aws_s3_bucket_object" "this" {
      - acl           = "private" -> null
      - bucket        = "safely-arguably-legally-alert-lamb-dev" -> null
      - content_type  = "application/zip" -> null
      - etag          = "04ded5bc7d6260411ee5f73b7d14df32" -> null
      - force_destroy = false -> null
      - id            = "32ec8b26-b36e-3338-b795-37966bc42095.zip" -> null
      - key           = "32ec8b26-b36e-3338-b795-37966bc42095.zip" -> null
      - metadata      = {} -> null
      - source        = "./files/meu-arquivo-gerado-de-um-template.zip" -> null
      - storage_class = "STANDARD" -> null
      - tags          = {
          - "Owner" = "Fernando Muller"
          - "Year"  = "2022"
        } -> null
    }

  # random_pet.bucket will be destroyed
  - resource "random_pet" "bucket" {
      - id        = "safely-arguably-legally-alert-lamb" -> null
      - length    = 5 -> null
      - separator = "-" -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.
aws_s3_bucket_object.this: Destroying... [id=32ec8b26-b36e-3338-b795-37966bc42095.zip]
aws_s3_bucket_object.this: Destruction complete after 0s
aws_s3_bucket.this: Destroying... [id=safely-arguably-legally-alert-lamb-dev]
aws_s3_bucket.this: Destruction complete after 1s
random_pet.bucket: Destroying... [id=safely-arguably-legally-alert-lamb]
random_pet.bucket: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$






terraform apply -auto-approve





fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ terraform apply -auto-approve
var.env
  Enter a value: dev


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.server[0] will be created
  + resource "aws_instance" "server" {
      + ami                          = "ami-04505e74c0741db8d"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = (known after apply)
      + outpost_arn                  = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + secondary_private_ips        = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Env"     = "dev"
          + "Name"    = "Instance 1"
          + "Owner"   = "Fernando Muller"
          + "Project" = "Curso AWS com Terraform"
          + "Year"    = "2022"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

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
      + tags                        = {
          + "Owner" = "Fernando Muller"
          + "Year"  = "2022"
        }
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
      + content_type           = "application/zip"
      + etag                   = "04ded5bc7d6260411ee5f73b7d14df32"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = (known after apply)
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./files/meu-arquivo-gerado-de-um-template.zip"
      + storage_class          = (known after apply)
      + tags                   = {
          + "Owner" = "Fernando Muller"
          + "Year"  = "2022"
        }
      + version_id             = (known after apply)
    }

  # random_pet.bucket will be created
  + resource "random_pet" "bucket" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

Plan: 4 to add, 0 to change, 0 to destroy.
random_pet.bucket: Creating...
random_pet.bucket: Creation complete after 0s [id=kindly-implicitly-ultimately-flexible-escargot]
aws_instance.server[0]: Creating...
aws_s3_bucket.this: Creating...
aws_instance.server[0]: Still creating... [10s elapsed]
aws_s3_bucket.this: Still creating... [10s elapsed]
aws_s3_bucket.this: Creation complete after 12s [id=kindly-implicitly-ultimately-flexible-escargot-dev]
aws_s3_bucket_object.this: Creating...
aws_s3_bucket_object.this: Creation complete after 2s [id=1fc50d01-e3cd-32a2-8845-a1d67c4cd139.zip]
aws_instance.server[0]: Still creating... [20s elapsed]
aws_instance.server[0]: Still creating... [30s elapsed]
aws_instance.server[0]: Still creating... [40s elapsed]
aws_instance.server[0]: Creation complete after 42s [id=i-0a117f7fbb755d9bf]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$ ^C



- O Terraform informa que foram criados 4 recursos:

 * Criada instancia EC2 na AWS com sucesso.
 * Criado o bucket usando nome random via random_pet.
 * Criado o objeto zipado, conforme o esperado.
 * Criado o recurso random_pet.




- Baixando o arquivo zipado e descompactando ele, o conteúdo do arquivo traz as informações esperadas.

- Antes de subir o arquivo para o bucket no S3, ele foi criado localmente, conforme o diretório “files”, contendo o arquivo zipado.






Plan: 0 to add, 0 to change, 4 to destroy.
aws_s3_bucket_object.this: Destroying... [id=1fc50d01-e3cd-32a2-8845-a1d67c4cd139.zip]
aws_instance.server[0]: Destroying... [id=i-0a117f7fbb755d9bf]
aws_s3_bucket_object.this: Destruction complete after 1s
aws_s3_bucket.this: Destroying... [id=kindly-implicitly-ultimately-flexible-escargot-dev]
aws_s3_bucket.this: Destruction complete after 1s
random_pet.bucket: Destroying... [id=kindly-implicitly-ultimately-flexible-escargot]
random_pet.bucket: Destruction complete after 0s
aws_instance.server[0]: Still destroying... [id=i-0a117f7fbb755d9bf, 10s elapsed]
aws_instance.server[0]: Still destroying... [id=i-0a117f7fbb755d9bf, 20s elapsed]
aws_instance.server[0]: Still destroying... [id=i-0a117f7fbb755d9bf, 30s elapsed]
aws_instance.server[0]: Destruction complete after 33s

Destroy complete! Resources: 4 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula18-Built-in-Functions$






- Video continua em 11:41
- Pendente, criar "outputs.tf".