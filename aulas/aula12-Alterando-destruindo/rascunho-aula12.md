

# 12. Alterando e destruindo

- Alterando somente as tags, o bucket não é destruído e criado novamente.


- Editando o main.tf da aula anterior:

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis/main.tf
~~~


- Adicionar as tags:
    Owner       = "Fernando Müller"
    UpdatedAt   = "03-02-2022"


- Aplicar as alterações:

~~~bash
terraform plan

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform plan
aws_s3_bucket.bucket-teste: Refreshing state... [id=meu-bucket-de-teste-via-terraform-02-03-2022]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste will be updated in-place
  ~ resource "aws_s3_bucket" "bucket-teste" {
        id                                   = "meu-bucket-de-teste-via-terraform-02-03-2022"
      ~ tags                                 = {
          + "Owner"       = "Fernando Müller"
          + "UpdatedAt"   = "03-02-2022"
[...]
[...]
Plan: 1 to add, 1 to change, 0 to destroy.

~~~



- Editando o main.tf da aula anterior novamente:

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis/main.tf
~~~

-  O Terraform tem um comando que auxilia na validação das alterações, é o comando "terraform validate":

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~


- Outro comando interessante é o "terraform fmt", ele formata o código do Terraform seguindo a formatação indicada pela Hashicorp:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform fmt
main.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~

- Antes:

~~~hcl
resource "aws_s3_bucket" "bucket-teste" {
  bucket = "meu-bucket-de-teste-via-terraform-02-03-2022"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby        = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt = "03-02-2022"
    Project         = "Curso do Cleber"
  }
}
~~~


- Depois:

~~~hcl
resource "aws_s3_bucket" "bucket-teste" {
  bucket = "meu-bucket-de-teste-via-terraform-02-03-2022"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby   = "Terraform"
    Owner       = "Fernando Müller"
    UpdatedAt   = "03-02-2022"
    Project     = "Curso do Cleber"
  }
}
~~~



- Usar o comando "terraform plan -out="tfplan.out"" para escrever a saída do terraform plan num arquivo:
- Observação:
    A mensagem "  ~ update in-place" na saída do terraform plan indica que o recurso não será destruído na ação.

terraform plan -out="tfplan.out"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform plan -out="tfplan.out"
aws_s3_bucket.bucket-teste: Refreshing state... [id=meu-bucket-de-teste-via-terraform-02-03-2022]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste will be updated in-place
  ~ resource "aws_s3_bucket" "bucket-teste" {
        id                                   = "meu-bucket-de-teste-via-terraform-02-03-2022"
      ~ tags                                 = {
          + "Owner"       = "Fernando Müller"
          + "Project"     = "Curso do Cleber"
          + "UpdatedAt"   = "03-02-2022"
            # (3 unchanged elements hidden)
        }
      ~ tags_all                             = {
          + "Owner"       = "Fernando Müller"
          + "Project"     = "Curso do Cleber"
          + "UpdatedAt"   = "03-02-2022"
            # (3 unchanged elements hidden)
        }
        # (17 unchanged attributes hidden)
    }

  # aws_s3_bucket_acl.acl-de-exemplo will be created
  + resource "aws_s3_bucket_acl" "acl-de-exemplo" {
      + acl    = "private"
      + bucket = "meu-bucket-de-teste-via-terraform-02-03-2022"
      + id     = (known after apply)

      + access_control_policy {
          + grant {
              + permission = (known after apply)

              + grantee {
                  + display_name  = (known after apply)
                  + email_address = (known after apply)
                  + id            = (known after apply)
                  + type          = (known after apply)
                  + uri           = (known after apply)
                }
            }

          + owner {
              + display_name = (known after apply)
              + id           = (known after apply)
            }
        }
    }

Plan: 1 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan.out"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~


- Verificando o arquivo out que foi criado:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ ls
main.tf  rascunho-aula11.md  terraform.tfstate  terraform.tfstate.backup  tfplan.out
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~


- Na saída do plan já vem o comando do apply usando o arquivo de out, pronto para ser usado:

terraform apply "tfplan.out"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform apply "tfplan.out"
aws_s3_bucket.bucket-teste: Modifying... [id=meu-bucket-de-teste-via-terraform-02-03-2022]
aws_s3_bucket.bucket-teste: Modifications complete after 3s [id=meu-bucket-de-teste-via-terraform-02-03-2022]
aws_s3_bucket_acl.acl-de-exemplo: Creating...
aws_s3_bucket_acl.acl-de-exemplo: Creation complete after 1s [id=meu-bucket-de-teste-via-terraform-02-03-2022,private]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~



- Alterado o nome do bucket:
de:
bucket = "meu-bucket-de-teste-via-terraform-02-03-2022"
para:
bucket = "meu-bucket-de-teste-via-terraform--novo-02-03-2022"

- Ao rodar o comando terraform plan -out="tfplan.out" novamente, existem algumas mensagens indicando que o recurso vai ser destruído
e vai ser criado novamente:
        -/+ destroy and then create replacement
        "# forces replacement"

terraform plan -out="tfplan.out"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform plan -out="tfplan.out"
aws_s3_bucket.bucket-teste: Refreshing state... [id=meu-bucket-de-teste-via-terraform-02-03-2022]
aws_s3_bucket_acl.acl-de-exemplo: Refreshing state... [id=meu-bucket-de-teste-via-terraform-02-03-2022,private]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste must be replaced
-/+ resource "aws_s3_bucket" "bucket-teste" {
      + acceleration_status                  = (known after apply)
      ~ acl                                  = "private" -> (known after apply)
      ~ arn                                  = "arn:aws:s3:::meu-bucket-de-teste-via-terraform-02-03-2022" -> (known after apply)
      ~ bucket                               = "meu-bucket-de-teste-via-terraform-02-03-2022" -> "meu-bucket-de-teste-via-terraform--novo-02-03-2022" # forces replacement

[...]
          ~ owner {
[...]

Plan: 2 to add, 0 to change, 2 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan.out"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~



-  Aplicando o novo plan da alteração do nome do bucket:

terraform apply "tfplan.out"

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform apply "tfplan.out"
aws_s3_bucket.bucket-teste: Destroying... [id=meu-bucket-de-teste-via-terraform-02-03-2022]
aws_s3_bucket.bucket-teste: Destruction complete after 1s
aws_s3_bucket.bucket-teste: Creating...
aws_s3_bucket.bucket-teste: Creation complete after 3s [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022]
aws_s3_bucket_acl.acl-de-exemplo: Creating...
aws_s3_bucket_acl.acl-de-exemplo: Creation complete after 1s [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022,private]

Apply complete! Resources: 2 added, 0 changed, 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~



- Para destruir o recurso que foi criado, usamos o destroy:

terraform destroy

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$ terraform destroy
aws_s3_bucket.bucket-teste: Refreshing state... [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022]
aws_s3_bucket_acl.acl-de-exemplo: Refreshing state... [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022,private]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.bucket-teste will be destroyed

    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_s3_bucket_acl.acl-de-exemplo: Destroying... [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022,private]
aws_s3_bucket_acl.acl-de-exemplo: Destruction complete after 0s
aws_s3_bucket.bucket-teste: Destroying... [id=meu-bucket-de-teste-via-terraform--novo-02-03-2022]
aws_s3_bucket.bucket-teste: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula11-Primeiro-script-com-variaveis$
~~~