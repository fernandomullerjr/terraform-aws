
# Aula 20. Foreach, for e splat operator
- Dia 03/04/2022.
- Criando os arquivos da aula.
<https://github.com/chgasparoto/curso-aws-com-terraform/tree/master/02-terraform-intermediario/04-foreach-for-splat>


ec2.tf

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

resource "aws_instance" "this" {
  for_each = {
    web = {
      name = "Web server"
      type = "t3a.micro"
    }
    ci_cd = {
      name = "CI/CD server"
      type = "t2.micro"
    }
  }

  ami           = data.aws_ami.ubuntu.id
  instance_type = lookup(each.value, "type", null)

  tags = {
    Project = "Curso AWS com Terraform"
    Name    = "${each.key}: ${lookup(each.value, "name", null)}"
    Lesson  = "Foreach, For, Splat"
  }
}
~~~



iam.tf

~~~hcl
resource "aws_iam_user" "the-accounts" {
  for_each = toset(["Todd", "James", "Alice", "Dottie"])
  name     = each.key # note: each.key and each.value are the same for a set
}
~~~




locals.tf

~~~hcl
locals {
  files                 = ["ips.json", "report.csv", "sitemap.xml"]
  file_extensions       = [for file in local.files : regex("\\.[0-9a-z]+$", file)]
  file_extensions_upper = { for f in local.file_extensions : f => upper(f) if f != ".json" }

  ips = [
    {
      public : "123.123.123.22",
      private : "123.123.123.23",
    },
    {
      public : "122.123.123.22",
      private : "122.123.123.23",
    }
  ]
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
output "extensions" {
  value = local.file_extensions
}

output "extensions_upper" {
  value = local.file_extensions_upper
}

output "instance_arns" {
  value = [for k, v in aws_instance.this : v.arn]
}

output "instance_names" {
  value = { for k, v in aws_instance.this : k => v.tags.Name }
}

output "private_ips" {
  value = [for o in local.ips : o.private]
}

output "public_ips" {
  value = local.ips[*].public
}
~~~


variables.tf

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




# for_each
<https://www.terraform.io/language/meta-arguments/for_each>

Um "Resource block" configura um objeto real na infraestrutura.
As vezes precisamos criar e gerenciar vários objetos similares, precisando escrever um bloco separado para cada um.
Usando o Terraform, temos 2 maneiras de evitar a necessidade de escrever um bloco de configuração para cada recurso:
    1 - count
    2 - for_each

As diferenças entre o count e o for_each são:
    O Count aceita um número.
    O for_each aceita um map ou um conjunto de strings.

- Basic Syntax
for_each is a meta-argument defined by the Terraform language. It can be used with modules and with every resource type.
The for_each meta-argument accepts a map or a set of strings, and creates an instance for each item in that map or set. Each instance has a distinct infrastructure object associated with it, and each is separately created, updated, or destroyed when the configuration is applied.


- Map:

~~~hcl
resource "azurerm_resource_group" "rg" {
  for_each = {
    a_group = "eastus"
    another_group = "westus2"
  }
  name     = each.key
  location = each.value
}
~~~




- Set of strings:

~~~hcl
resource "aws_iam_user" "the-accounts" {
  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
  name     = each.key
}
~~~




- Child module:

~~~hcl
# my_buckets.tf
module "bucket" {
  for_each = toset(["assets", "media"])
  source   = "./publish_bucket"
  name     = "${each.key}_bucket"
}
~~~

~~~hcl
# publish_bucket/bucket-and-cloudfront.tf
variable "name" {} # this is the input parameter of the module

resource "aws_s3_bucket" "example" {
  # Because var.name includes each.key in the calling
  # module block, its value will be different for
  # each instance of this module.
  bucket = var.name

  # ...
}

resource "aws_iam_user" "deploy_user" {
  # ...
}
~~~





# Using Sets

The Terraform language doesn't have a literal syntax for set values, but you can use the toset function to explicitly convert a list of strings to a set:

~~~hcl
locals {
  subnet_ids = toset([
    "subnet-abcdef",
    "subnet-012345",
  ])
}

resource "aws_instance" "server" {
  for_each = local.subnet_ids

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = each.key # note: each.key and each.value are the same for a set

  tags = {
    Name = "Server ${each.key}"
  }
}
~~~


- A função toset converte uma lista de strings em um conjunto(set).



- No nosso projeto criamos o arquivo main.tf com a estrutura básica do Provider.
- No arquivo ec2.tf, buscamos o valor do id da ami usando o Data Source "aws_ami".
- No arquivo ec2.tf, criamos 2 chaves:
    1 - web
    2 - ci_cd
- Dentro das chaves criamos 2 Maps
    1 - Name e Type para a chave Web.
    2 - Name e Type para a chave ci_cd.


- No nosso código o "each.key" seria:
    web = {

ou 

    ci_cd = {



- Enquanto que o "each.value" seriam os Maps:

      name = "Web server"
      type = "t3a.micro"
    }

ou

      name = "CI/CD server"
      type = "t2.micro"
    }



- Acessando o valor do Map chamado type, colocando um valor null caso ele não seja encontrado:
    instance_type = lookup(each.value, "type", null)


- Nas tags usamos o for_each, acessando os valores da Key e dos Value, exemplo:
    Name    = "${each.key}: ${lookup(each.value, "name", null)}"

Neste caso seria o equivalente a dizer que a Tag vai ser:
Web:Web Server
ou
ci_cd:CI/CD Server



- Inicializando o projeot Terraform:
terraform init

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform init

Initializing the backend...

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$
~~~




- Efetuando o Plan.
- É possível verificar que o Terraform vai criar os usuários do IAM, conforme a listagem e vai criar 2 instancias
terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.the-accounts["Alice"] will be created
[...]
Plan: 6 to add, 0 to change, 0 to destroy.
# aws_instance.this["ci_cd"] will be created
  + resource "aws_instance" "this" {
  + tags                         = {
          + "Lesson"  = "Foreach, For, Splat"
          + "Name"    = "ci_cd: CI/CD server"
          + "Project" = "Curso AWS com Terraform"

  # aws_instance.this["web"] will be created
  + resource "aws_instance" "this" {
      + ami                          = "ami-015cfeb4e0d6306b2"
  + tags                         = {
          + "Lesson"  = "Foreach, For, Splat"
          + "Name"    = "web: Web server"
          + "Project" = "Curso AWS com Terraform"

Changes to Outputs:
  + extensions       = [
      + ".json",
      + ".csv",
      + ".xml",
    ]
  + extensions_upper = {
      + .csv = ".CSV"
      + .xml = ".XML"
    }
  + instance_arns    = [
      + (known after apply),
      + (known after apply),
    ]
  + instance_names   = {
      + ci_cd = "ci_cd: CI/CD server"
      + web   = "web: Web server"
    }
  + private_ips      = [
      + "123.123.123.23",
      + "122.123.123.23",
    ]
  + public_ips       = [
      + "123.123.123.22",
      + "122.123.123.22",
    ]

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$
~~~





- Efetuando o Apply.
terraform apply -auto-approve

~~~bash
aws_instance.this["web"]: Creating...
aws_iam_user.the-accounts["James"]: Creating...
aws_iam_user.the-accounts["Dottie"]: Creating...
aws_iam_user.the-accounts["Alice"]: Creating...
aws_iam_user.the-accounts["Todd"]: Creating...
aws_instance.this["ci_cd"]: Creating...
aws_iam_user.the-accounts["Todd"]: Creation complete after 1s [id=Todd]
aws_iam_user.the-accounts["Dottie"]: Creation complete after 1s [id=Dottie]
aws_iam_user.the-accounts["James"]: Creation complete after 1s [id=James]
aws_iam_user.the-accounts["Alice"]: Creation complete after 1s [id=Alice]
aws_instance.this["web"]: Still creating... [10s elapsed]
aws_instance.this["ci_cd"]: Still creating... [10s elapsed]
aws_instance.this["web"]: Creation complete after 19s [id=i-0cb0a3d60de140645]
aws_instance.this["ci_cd"]: Still creating... [20s elapsed]
aws_instance.this["ci_cd"]: Still creating... [30s elapsed]
aws_instance.this["ci_cd"]: Still creating... [40s elapsed]
aws_instance.this["ci_cd"]: Creation complete after 41s [id=i-080275a5f2fd475a2]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

extensions = [
  ".json",
  ".csv",
  ".xml",
]
extensions_upper = {
  ".csv" = ".CSV"
  ".xml" = ".XML"
}
instance_arns = [
  "arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2",
  "arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645",
]
instance_names = {
  "ci_cd" = "ci_cd: CI/CD server"
  "web" = "web: Web server"
}
private_ips = [
  "123.123.123.23",
  "122.123.123.23",
]
public_ips = [
  "123.123.123.22",
  "122.123.123.22",
]
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$
~~~



- Explicando sobre a criação dos usuários do IAM.
- Usamos a função [toset] para converter a lista de strings em um conjunto[set].
- Usamos o [each.key], já que o valor é igual a chave, neste caso.
Todd = Todd
James = James
Alice = Alice
Dottie = Dottie

~~~hcl
resource "aws_iam_user" "the-accounts" {
  for_each = toset(["Todd", "James", "Alice", "Dottie"])
  name     = each.key # note: each.key and each.value are the same for a set
}
~~~




# Expressão for
<https://www.terraform.io/language/expressions/for>
A for expression creates a complex type value by transforming another complex type value. Each element in the input value can correspond to either one or zero values in the result, and an arbitrary expression can be used to transform each input element into an output element.

For example, if var.list were a list of strings, then the following expression would produce a tuple of strings with all-uppercase letters:
    [for s in var.list : upper(s)]

- No exemplo, usamos a função [upper] para passar as letras da string para maiusculo(uppercase).

Ao usar o colchete o valor retornado é uma lista.
[ ] - tuple

Ao usar as chaves para abrir e fechar a expressão, o valor retornado vai ser um map.
{ } - object


# Função upper
<https://www.terraform.io/language/functions/upper>
upper converts all cased letters in the given string to uppercase.
- No exemplo, usamos a função [upper] para passar as letras da string para maiusculo(uppercase).

- Examples:
> upper("hello")
HELLO
> upper("алло!")
АЛЛО!




- No nosso arquivo locals.tf usamos uma expressão for.

~~~hcl
locals {
  files                 = ["ips.json", "report.csv", "sitemap.xml"]
  file_extensions       = [for file in local.files : regex("\\.[0-9a-z]+$", file)]
  file_extensions_upper = { for f in local.file_extensions : f => upper(f) if f != ".json" }

  ips = [
    {
      public : "123.123.123.22",
      private : "123.123.123.23",
    },
    {
      public : "122.123.123.22",
      private : "122.123.123.23",
    }
  ]
}
~~~



- Para trazer uma lista, usamos os colchetes.
- Para cada File dentro de Files, após os dois pontos é o resultado da expressão. Usamos uma função dentro dela.
- Usamos um regex que pega tudo que vem depois do ponto, colocamos as possibilidades de números e letras. O sinal de mais e o cifrão dizem para pegar tudo que vem depois.
- O parametro "file" que vem ao final é a string da onde iremos procurar.


- Explicando mais sobre o regex:
<https://regex101.com/>
/
\\.[0-9a-z]+$
/
gm
    \\ matches the character \ with index 9210 (5C16 or 1348) literally (case sensitive)
    . matches any character (except for line terminators)
    Match a single character present in the list below [0-9a-z]
    + matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
    0-9 matches a single character in the range between 0 (index 48) and 9 (index 57) (case sensitive)
    a-z matches a single character in the range between a (index 97) and z (index 122) (case sensitive)
    $ asserts position at the end of a line
Global pattern flags 
    g modifier: global. All matches (don't return after first match)
    m modifier: multi line. Causes ^ and $ to match the begin/end of each line (not only begin/end of string)




- Para verificar se uma regex está retornando o valor esperado e se a expressão está correta, podemos usar o Terraform Console
terraform console

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for file in local.files : regex("\\.[0-9a-z]+$", file)]
[
  ".json",
  ".csv",
  ".xml",
]
>
~~~


> [for file in local.files : regex("\\.[0-9a-z]+$", file)]
[
  ".json",
  ".csv",
  ".xml",
]
>


- Outra maneira de obter os valores da expressão e checar se ela está trazendo os valores esperados é jogando os valores para os Outputs.

~~~hcl
output "extensions" {
  value = local.file_extensions
}
~~~





- Agora, sobre os Outputs da arn.

~~~hcl
output "instance_arns" {
  value = [for k, v in aws_instance.this : v.arn]
}
~~~


- Usando o Terraform Console para trazer todos os detalhes da EC2:
terraform console

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> aws_instance.this
{
  "ci_cd" = {
    "ami" = "ami-015cfeb4e0d6306b2"
    "arn" = "arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2"
    "associate_public_ip_address" = true
    "availability_zone" = "us-east-1b"
    "cpu_core_count" = 1
    "cpu_threads_per_core" = 1
    "credit_specification" = tolist([
      {
        "cpu_credits" = "standard"
      },
    ])
    "disable_api_termination" = false
    "ebs_block_device" = toset([])
    "ebs_optimized" = false
    "enclave_options" = tolist([
      {
        "enabled" = false
      },
    ])
    "ephemeral_block_device" = toset([])
    "get_password_data" = false
    "hibernation" = false
    "host_id" = tostring(null)
    "iam_instance_profile" = ""
    "id" = "i-080275a5f2fd475a2"
    "instance_initiated_shutdown_behavior" = tostring(null)
    "instance_state" = "running"
    "instance_type" = "t2.micro"
    "ipv6_address_count" = 0
    "ipv6_addresses" = tolist([])
    "key_name" = ""
    "metadata_options" = tolist([
      {
        "http_endpoint" = "enabled"
        "http_put_response_hop_limit" = 1
        "http_tokens" = "optional"
      },
    ])
    "monitoring" = false
    "network_interface" = toset([])
    "outpost_arn" = ""
    "password_data" = ""
    "placement_group" = ""
    "primary_network_interface_id" = "eni-0a667d48e23001b89"
    "private_dns" = "ip-172-31-92-20.ec2.internal"
    "private_ip" = "172.31.92.20"
    "public_dns" = "ec2-18-206-249-161.compute-1.amazonaws.com"
    "public_ip" = "18.206.249.161"
    "root_block_device" = tolist([
      {
        "delete_on_termination" = true
        "device_name" = "/dev/sda1"
        "encrypted" = false
        "iops" = 105
        "kms_key_id" = ""
        "throughput" = 0
        "volume_id" = "vol-0f57fac1242ae404c"
        "volume_size" = 35
        "volume_type" = "gp2"
      },
    ])
    "secondary_private_ips" = toset([])
    "security_groups" = toset([
      "default",
    ])
    "source_dest_check" = true
    "subnet_id" = "subnet-817c58a0"
    "tags" = tomap({
      "Lesson" = "Foreach, For, Splat"
      "Name" = "ci_cd: CI/CD server"
      "Project" = "Curso AWS com Terraform"
    })
    "tenancy" = "default"
    "timeouts" = null /* object */
    "user_data" = tostring(null)
    "user_data_base64" = tostring(null)
    "volume_tags" = tomap({})
    "vpc_security_group_ids" = toset([
      "sg-ce5ae9d2",
    ])
  }
  "web" = {
    "ami" = "ami-015cfeb4e0d6306b2"
    "arn" = "arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645"
    "associate_public_ip_address" = true
    "availability_zone" = "us-east-1f"
    "cpu_core_count" = 1
    "cpu_threads_per_core" = 2
    "credit_specification" = tolist([
      {
        "cpu_credits" = "unlimited"
      },
    ])
    "disable_api_termination" = false
    "ebs_block_device" = toset([])
    "ebs_optimized" = false
    "enclave_options" = tolist([
      {
        "enabled" = false
      },
    ])
    "ephemeral_block_device" = toset([])
    "get_password_data" = false
    "hibernation" = false
    "host_id" = tostring(null)
    "iam_instance_profile" = ""
    "id" = "i-0cb0a3d60de140645"
    "instance_initiated_shutdown_behavior" = tostring(null)
    "instance_state" = "running"
    "instance_type" = "t3a.micro"
    "ipv6_address_count" = 0
    "ipv6_addresses" = tolist([])
    "key_name" = ""
    "metadata_options" = tolist([
      {
        "http_endpoint" = "enabled"
        "http_put_response_hop_limit" = 1
        "http_tokens" = "optional"
      },
    ])
    "monitoring" = false
    "network_interface" = toset([])
    "outpost_arn" = ""
    "password_data" = ""
    "placement_group" = ""
    "primary_network_interface_id" = "eni-066a5c1eaa193f3ab"
    "private_dns" = "ip-172-31-68-238.ec2.internal"
    "private_ip" = "172.31.68.238"
    "public_dns" = "ec2-44-200-79-149.compute-1.amazonaws.com"
    "public_ip" = "44.200.79.149"
    "root_block_device" = tolist([
      {
        "delete_on_termination" = true
        "device_name" = "/dev/sda1"
        "encrypted" = false
        "iops" = 105
        "kms_key_id" = ""
        "throughput" = 0
        "volume_id" = "vol-01a0556bfe49bcd07"
        "volume_size" = 35
        "volume_type" = "gp2"
      },
    ])
    "secondary_private_ips" = toset([])
    "security_groups" = toset([
      "default",
    ])
    "source_dest_check" = true
    "subnet_id" = "subnet-55f4e45b"
    "tags" = tomap({
      "Lesson" = "Foreach, For, Splat"
      "Name" = "web: Web server"
      "Project" = "Curso AWS com Terraform"
    })
    "tenancy" = "default"
    "timeouts" = null /* object */
    "user_data" = tostring(null)
    "user_data_base64" = tostring(null)
    "volume_tags" = tomap({})
    "vpc_security_group_ids" = toset([
      "sg-ce5ae9d2",
    ])
  }
}
>
~~~



- Com a saída acima dos detalhes das instancias EC2, podemos certificar que ela é um valor do tipo Map, devido
    {
    "ci_cd" = {
        [...]
    }
    "web" = {


- Devido o uso do arquivo Outputs.tf com este código:

~~~hcl
output "instance_arns" {
  value = [for k, v in aws_instance.this : v.arn]
}
~~~


- Este output traz estas informações das ARN das 2 instancias EC2 do Map:

~~~bash
instance_arns = [
  "arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2",
  "arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645",
]
~~~


- Explicando melhor a expressão for com Map.
<https://www.terraform.io/language/expressions/for>
A entrada da expressão for (fornecida após a palavra-chave in) pode ser uma lista, um conjunto, uma tupla, um mapa ou um objeto.
O primeiro exemplo mostrou uma expressão for com apenas um único símbolo temporário s, mas uma expressão for pode opcionalmente declarar um par de símbolos temporários para usar a chave ou índice de cada item também:
    [para k, v em var.map : comprimento(k) + comprimento(v)]



- Input Types
<https://www.terraform.io/language/expressions/for>
A for expression's input (given after the in keyword) can be a list, a set, a tuple, a map, or an object.

The above example showed a for expression with only a single temporary symbol s, but a for expression can optionally declare a pair of temporary symbols in order to use the key or index of each item too:

    [for k, v in var.map : length(k) + length(v)]

For a map or object type, like above, the k symbol refers to the key or attribute name of the current element. You can also use the two-symbol form with lists and tuples, in which case the additional symbol is the index of each element starting from zero, which conventionally has the symbol name i or idx unless it's helpful to choose a more specific name:

    [for i, v in var.list : "${i} is ${v}"]

The index or key symbol is always optional. If you specify only a single symbol after the for keyword then that symbol will always represent the value of each element of the input collection.



- Explicando o for do Output do ARN.

~~~hcl
output "instance_arns" {
  value = [for k, v in aws_instance.this : v.arn]
}
~~~

O "k" e o "v" seriam:
    k:v
    chave:valor
Que seriam acessados em "aws_instance.this", que trazem os valores das 2 instancias:
    k:v
    "ci_cd":"ami"
    "ci_cd":"arn"
    "ci_cd":"availability_zone"
    "web":"ami"
    "web":"arn"
    "web":"availability_zone"
Como o resultado da expressão é só o v.arn, ele traz apenas a arn da instancia EC2.
Seria algo como:
    ci_cd:arn:"arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2"


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for k, v in aws_instance.this : v.arn]
[
  "arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2",
  "arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645",
]
>











- Testando as expressões via Terraform console:
[for k, v in aws_instance.this : v]

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for k, v in aws_instance.this : v]
[
  {
    "ami" = "ami-015cfeb4e0d6306b2"
    "arn" = "arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2"
    "associate_public_ip_address" = true
    "availability_zone" = "us-east-1b"
    "cpu_core_count" = 1
    "cpu_threads_per_core" = 1
    "credit_specification" = tolist([
      {
        "cpu_credits" = "standard"
      },
    ])
    "disable_api_termination" = false
    "ebs_block_device" = toset([])
    "ebs_optimized" = false
    "enclave_options" = tolist([
      {
        "enabled" = false
      },
    ])
    "ephemeral_block_device" = toset([])
    "get_password_data" = false
    "hibernation" = false
    "host_id" = tostring(null)
    "iam_instance_profile" = ""
    "id" = "i-080275a5f2fd475a2"
    "instance_initiated_shutdown_behavior" = tostring(null)
    "instance_state" = "running"
    "instance_type" = "t2.micro"
    "ipv6_address_count" = 0
    "ipv6_addresses" = tolist([])
    "key_name" = ""
    "metadata_options" = tolist([
      {
        "http_endpoint" = "enabled"
        "http_put_response_hop_limit" = 1
        "http_tokens" = "optional"
      },
    ])
    "monitoring" = false
    "network_interface" = toset([])
    "outpost_arn" = ""
    "password_data" = ""
    "placement_group" = ""
    "primary_network_interface_id" = "eni-0a667d48e23001b89"
    "private_dns" = "ip-172-31-92-20.ec2.internal"
    "private_ip" = "172.31.92.20"
    "public_dns" = "ec2-18-206-249-161.compute-1.amazonaws.com"
    "public_ip" = "18.206.249.161"
    "root_block_device" = tolist([
      {
        "delete_on_termination" = true
        "device_name" = "/dev/sda1"
        "encrypted" = false
        "iops" = 105
        "kms_key_id" = ""
        "throughput" = 0
        "volume_id" = "vol-0f57fac1242ae404c"
        "volume_size" = 35
        "volume_type" = "gp2"
      },
    ])
    "secondary_private_ips" = toset([])
    "security_groups" = toset([
      "default",
    ])
    "source_dest_check" = true
    "subnet_id" = "subnet-817c58a0"
    "tags" = tomap({
      "Lesson" = "Foreach, For, Splat"
      "Name" = "ci_cd: CI/CD server"
      "Project" = "Curso AWS com Terraform"
    })
    "tenancy" = "default"
    "timeouts" = null /* object */
    "user_data" = tostring(null)
    "user_data_base64" = tostring(null)
    "volume_tags" = tomap({})
    "vpc_security_group_ids" = toset([
      "sg-ce5ae9d2",
    ])
  },
  {
    "ami" = "ami-015cfeb4e0d6306b2"
    "arn" = "arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645"
    "associate_public_ip_address" = true
    "availability_zone" = "us-east-1f"
    "cpu_core_count" = 1
    "cpu_threads_per_core" = 2
    "credit_specification" = tolist([
      {
        "cpu_credits" = "unlimited"
      },
    ])
    "disable_api_termination" = false
    "ebs_block_device" = toset([])
    "ebs_optimized" = false
    "enclave_options" = tolist([
      {
        "enabled" = false
      },
    ])
    "ephemeral_block_device" = toset([])
    "get_password_data" = false
    "hibernation" = false
    "host_id" = tostring(null)
    "iam_instance_profile" = ""
    "id" = "i-0cb0a3d60de140645"
    "instance_initiated_shutdown_behavior" = tostring(null)
    "instance_state" = "running"
    "instance_type" = "t3a.micro"
    "ipv6_address_count" = 0
    "ipv6_addresses" = tolist([])
    "key_name" = ""
    "metadata_options" = tolist([
      {
        "http_endpoint" = "enabled"
        "http_put_response_hop_limit" = 1
        "http_tokens" = "optional"
      },
    ])
    "monitoring" = false
    "network_interface" = toset([])
    "outpost_arn" = ""
    "password_data" = ""
    "placement_group" = ""
    "primary_network_interface_id" = "eni-066a5c1eaa193f3ab"
    "private_dns" = "ip-172-31-68-238.ec2.internal"
    "private_ip" = "172.31.68.238"
    "public_dns" = "ec2-44-200-79-149.compute-1.amazonaws.com"
    "public_ip" = "44.200.79.149"
    "root_block_device" = tolist([
      {
        "delete_on_termination" = true
        "device_name" = "/dev/sda1"
        "encrypted" = false
        "iops" = 105
        "kms_key_id" = ""
        "throughput" = 0
        "volume_id" = "vol-01a0556bfe49bcd07"
        "volume_size" = 35
        "volume_type" = "gp2"
      },
    ])
    "secondary_private_ips" = toset([])
    "security_groups" = toset([
      "default",
    ])
    "source_dest_check" = true
    "subnet_id" = "subnet-55f4e45b"
    "tags" = tomap({
      "Lesson" = "Foreach, For, Splat"
      "Name" = "web: Web server"
      "Project" = "Curso AWS com Terraform"
    })
    "tenancy" = "default"
    "timeouts" = null /* object */
    "user_data" = tostring(null)
    "user_data_base64" = tostring(null)
    "volume_tags" = tomap({})
    "vpc_security_group_ids" = toset([
      "sg-ce5ae9d2",
    ])
  },
]
>
~~~






- Testando as expressões via Terraform console:
[for k, v in aws_instance.this : k]

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for k, v in aws_instance.this : k]
[
  "ci_cd",
  "web",
]
>
~~~







- Testando as expressões via Terraform console:
[for k, v in aws_instance.this : k.arn]

~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for k, v in aws_instance.this : k.arn]
╷
│ Error: Unsupported attribute
│
│   on <console-input> line 1:
│   (source code not available)
│
│ Can't access attributes on a primitive-typed value (string).
╵
╷
│ Error: Unsupported attribute
│
│   on <console-input> line 1:
│   (source code not available)
│
│ Can't access attributes on a primitive-typed value (string).
╵
>
~~~





- Testando as expressões via Terraform console:
[for k, v in aws_instance.this : v.private_ip]

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for k, v in aws_instance.this : v.private_ip]
[
  "172.31.92.20",
  "172.31.68.238",
]
>
~~~

Ele traz o ip privado das 2 instancias.






- Verificando os nomes das instancias.
- Este Output retorna os nomes com base na chave k, atribuindo a elas o valor da Tag Name do value v.
~~~hcl
output "instance_names" {
  value = { for k, v in aws_instance.this : k => v.tags.Name }
}
~~~

- Verificando via Terraform Console:
terraform console
    { for k, v in aws_instance.this : k => v.tags.Name }

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> { for k, v in aws_instance.this : k => v.tags.Name }
{
  "ci_cd" = "ci_cd: CI/CD server"
  "web" = "web: Web server"
}
>
~~~


O Sinal de igual e maior => define o valor que queremos para aquela variável.
Observação: como a expressão está entre chaves, o resultado será um Map com chave e valor.
Que no caso é o retorno daquele Output:
~~~bash
instance_names = {
  "ci_cd" = "ci_cd: CI/CD server"
  "web" = "web: Web server"
}
~~~




# If
<https://www.terraform.io/language/expressions/for>
Filtering Elements
A for expression can also include an optional if clause to filter elements from the source collection, producing a value with fewer elements than the source value:
    [for s in var.list : upper(s) if s != ""]

- No nosso caso usamos o if para remover o que consta .json
    file_extensions_upper = { for f in local.file_extensions : f => upper(f) if f != ".json" }

- Explicando o if:
    if f != ".json"
    Se for diferente de .json

- Resultado do local "file_extensions_upper" é um Map:
~~~bash
extensions_upper = {
  ".csv" = ".CSV"
  ".xml" = ".XML"
}
~~~






# Splat Expression
<https://www.terraform.io/language/expressions/splat>
A splat expression provides a more concise way to express a common operation that could otherwise be performed with a for expression.

If var.list is a list of objects that all have an attribute id, then a list of the ids could be produced with the following for expression:
    [for o in var.list : o.id]
This is equivalent to the following splat expression:
    var.list[*].id

The special [*] symbol iterates over all of the elements of the list given to its left and accesses from each one the attribute name given on its right. A splat expression can also be used to access attributes and indexes from lists of complex types by extending the sequence of operations to the right of the symbol:
    var.list[*].interfaces[0].name
The above expression is equivalent to the following for expression:
    [for o in var.list : o.interfaces[0].name]


- No nosso caso usamos o Splat expression [*] para acessar todos os valores de ips do local ips. Depois do ponto especificamos que queremos os ips públicos.
~~~hcl
output "private_ips" {
  value = [for o in local.ips : o.private]
}

output "public_ips" {
  value = local.ips[*].public
}
~~~



~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> [for o in local.ips : o.private]
[
  "123.123.123.23",
  "122.123.123.23",
]
> ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$ terraform console
> local.ips[*].public
[
  "123.123.123.22",
  "122.123.123.22",
]
>
~~~




- Efetuando destroy
terraform destroy -auto-approve

Destroy complete! Resources: 6 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula20-Foreach-for-splat-operator$
