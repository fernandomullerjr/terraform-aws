


# Aula 10. Primeiro script

- Acessar o site do Terraform e ir no Provider AWS:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs>

- Procurar na documentação por S3 > aws_s3_bucket:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>


- Copiar as entradas do arquivo .gitignore do material, para o arquivo .gitignore do projeto das aulas do curso.

~~~bash
*.dll
*.exe
.DS_Store
example.tf
terraform.tfplan
terraform.tfstate
bin/
modules-dev/
/pkg/
website/.vagrant
website/.bundle
website/build
website/node_modules
.vagrant/
*.backup
./*.tfstate
.terraform/
*.log
*.bak
*~
.*.swp
.idea
*.iml
*.test
*.iml

website/vendor

# Test exclusions
!command/test-fixtures/**/*.tfstate
!command/test-fixtures/**/.terraform/

node_modules/
*.zip
tfplan.out
plan.tfout
~~~



- Ficando assim o nosso arquivo:

~~~bash
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Ignore any .tfvars files that are generated automatically for each Terraform run. Most
# .tfvars files are managed as part of configuration and so should be included in
# version control.
#
# example.tfvars

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
#
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*


*.dll
*.exe
.DS_Store
example.tf
terraform.tfplan
terraform.tfstate
bin/
modules-dev/
/pkg/
website/.vagrant
website/.bundle
website/build
website/node_modules
.vagrant/
*.backup
./*.tfstate
.terraform/
*.log
*.bak
*~
.*.swp
.idea
*.iml
*.test
*.iml

website/vendor

# Test exclusions
!command/test-fixtures/**/*.tfstate
!command/test-fixtures/**/.terraform/

node_modules/
*.zip
tfplan.out
plan.tfout
~~~



## Criando arquivo main

- Primeiro passo é criar um arquivo chamado "main.tf" na pasta do projeto.

~~~bash
vi /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula10-Primeiro-script/main.tf
~~~

- Copiar no site do Terraform o bloco de código que cria o Bucket do S3.
- Definir o provider AWS no código do main.tf.
- Colar o bloco de código do bucket do S3.

- Exemplo do site da Terraform:

~~~hcl
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
~~~