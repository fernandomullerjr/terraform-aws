



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

- A função [substr] tira uma parte da string, conforme os parametros informados.
- Neste caso ela vai pegar o que vier a partir de 0(começo da string), vai começar na posição 0 e vai tirar 4 caracteres.
- Os 4 caracteres removidos serão "ami-".
    <https://www.terraform.io/language/functions/substr>
~~~hcl
condition     = length(var.instance_ami) > 4 && substr(var.instance_ami, 0, 4) == "ami-"
~~~


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




fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform state list
data.aws_caller_identity.current
aws_dynamodb_table.lock-table
aws_s3_bucket.remote-state
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$



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




- Foi necessário remover os objetos versionados, para poder seguir com o destroy do S3.







# Reforçar
- 
<https://www.terraform.io/language/functions/substr>

oPERATORS
<https://www.terraform.io/language/expressions/operators>

- Conditional Expressions
<https://www.terraform.io/language/expressions/conditionals>
  condition ? true_val : false_val
If condition is true then the result is true_val. If condition is false then the result is false_val.

A common use of conditional expressions is to define defaults to replace invalid values:
  var.a != "" ? var.a : "default-a"
If var.a is an empty string then the result is "default-a", but otherwise it is the actual value of var.a.