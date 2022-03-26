



# Aula 17. Remote state no S3


# Remote State
- Com o Remote State, podemos acessar os valores de Outputs em outras configurações, usando o Tfstate como Data Source.


# Criando bucket S3
- Criar um bucket que vai armazenar os Remote States remotos.
- Observação, a Hashicorp indica que seja ativado o versionamento no Bucket, em caso de exclusão acidental, possa acontecer a recuperação:
    <https://www.terraform.io/language/settings/backends/s3>
    Warning! It is highly recommended that you enable Bucket Versioning on the S3 bucket to allow for state recovery in the case of accidental deletions and human error.

- Criar o arquivo [main.tf] na pasta [00-remote-state-bucket]:
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket/main.tf

- O [data] server para puxar informações de sua conta, basicamente.
- o [resource] cria recursos na nossa infra.
- O nome do bucket é criado usando interpolação:
~~~hcl
    bucket = "tfstate-${data.aws_caller_identity.current.account_id}"
~~~

- Acessar o diretório e executar o init e apply.
~~~bash
cd cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket/
~~~



- Ocorreu erro devido a versão do Terraform no [main.tf]:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform init
╷
│ Error: Unsupported Terraform Core version
│
│   on main.tf line 2, in terraform:
│    2:   required_version = "0.14.4"
│
│ This configuration does not support Terraform version 1.1.5. To proceed, either choose another supported Terraform version or update this version constraint. Version constraints are normally set for good reason, so updating the constraint may lead to other errors
│ or unexpected behavior.
╵

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$
~~~



- Ajustada a versão para 1.1.5 e executado novamente:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform init

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$
~~~




- Efetuando o apply, para criar o bucket no S3:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.lock-table will be created
  + resource "aws_dynamodb_table" "lock-table" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "tflock-tfstate-816678621138"
      + read_capacity    = 5
      [.................]
        }
    }

  # aws_s3_bucket.remote-state will be created
  + resource "aws_s3_bucket" "remote-state" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "tfstate-816678621138"
[.................]
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + remote_state_bucket     = "tfstate-816678621138"
  + remote_state_bucket_arn = (known after apply)

aws_s3_bucket.remote-state: Creating...
aws_s3_bucket.remote-state: Still creating... [10s elapsed]
aws_s3_bucket.remote-state: Creation complete after 13s [id=tfstate-816678621138]
aws_dynamodb_table.lock-table: Creating...
aws_dynamodb_table.lock-table: Creation complete after 9s [id=tflock-tfstate-816678621138]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

remote_state_bucket = "tfstate-816678621138"
remote_state_bucket_arn = "arn:aws:s3:::tfstate-816678621138"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/00-remote-state-bucket$
~~~








# EC2

- Criar arquivos para subir uma EC2, com base nos arquivos:
    <https://github.com/chgasparoto/curso-aws-com-terraform/tree/master/02-terraform-intermediario/01-remote-state/01-usando-remote-state>

- Editar o ami id, conforme a região, pegar o ami id na AWS.
- Ubuntu20 na Virginia:
ami-04505e74c0741db8d

- Deixei o backend comentado no arquivo [main.tf] da EC2, por enquanto, pois vamos criar a EC2 sem ter o Backend remoto ainda.

- Acessar o diretório com as configurações da EC2:
cd cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3/

- Efetuar o init do Terraform:

terraform init

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~



- Aplicando o lançamento da EC2 sem Backend Remote:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                          = "ami-04505e74c0741db8d"

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Still creating... [20s elapsed]
aws_instance.web: Still creating... [30s elapsed]
aws_instance.web: Still creating... [40s elapsed]
aws_instance.web: Creation complete after 41s [id=i-0ba7d4d956a243777]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~



- Pegando no site do Terraform a configuração de exemplo, para configurar o Backend remoto via S3:
    <https://www.terraform.io/language/settings/backends/s3>

~~~hcl
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
~~~


- Adicionar configuração do Backend no arquivo [main.tf]:
  aulas/aula17-Remote-state-no-S3/main.tf

~~~hcl
terraform {
  backend "s3" {
    bucket = "tfstate-816678621138"
    key    = "dev/01-usando-remote-state/terraform.tfstate"
    region = "us-east-1"
    profile = "fernandomuller"
  }
}
~~~


- Observação
  no arquivo [main.tf] onde é declarado o Terraform não é possível usar interpolação, nenhuma função ou variáveis, pois ele é o primeiro bloco a ser criado.


- Arquivo [main.tf] ficou assim:

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
    bucket = "tfstate-816678621138"
    key    = "dev/01-usando-remote-state/terraform.tfstate"
    region = "us-east-1"
    profile = "fernandomuller"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
~~~



- Executar um terraform init para inicializar o backend.
- Preencher com "yes".

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.23.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~




- Adicionada uma tag no arquivo [ec2.tf], para testar o Remote State.
  Project  = "TestRemote"
- Efetuando formatação do código e apply.
terraform fmt
terraform apply


~~~hcl
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform fmt
ec2.tf
main.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform apply
aws_instance.web: Refreshing state... [id=i-0ba7d4d956a243777]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                           = "i-0ba7d4d956a243777"
      ~ tags                         = {
          + "Project" = "TestRemote"
            # (2 unchanged elements hidden)
        }
        # (27 unchanged attributes hidden)
        # (4 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Modifying... [id=i-0ba7d4d956a243777]
aws_instance.web: Modifications complete after 6s [id=i-0ba7d4d956a243777]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~



- Acessando o Bucket do S3 e ativando “Show versions”, podemos ver que o objeto do tfstate tem 2 versões, indicando que ele versionou após alteração que fizemos no recurso da EC2.



- Se removermos o bloco sobre o Backend no S3 e efetuarmos o init novamente, ele vai pedir os valores manualmente.
  aulas/aula17-Remote-state-no-S3/main.tf

DE:
~~~hcl
  backend "s3" {
    bucket  = "tfstate-816678621138"
    key     = "dev/01-usando-remote-state/terraform.tfstate"
    region  = "us-east-1"
    profile = "fernandomuller"
  }
~~~

PARA:
~~~hcl
  backend "s3" {}
~~~



- Usar o terraform init novamente.
- Passando a opção [reconfigure] ele vai pedir os valores manualmente.
terraform init
terraform init -reconfigure

  -reconfigure            Reconfigure a backend, ignoring any saved
                          configuration.

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init

Initializing the backend...
╷
│ Error: Backend configuration changed
│
│ A change in the backend configuration has been detected, which may require migrating existing state.
│
│ If you wish to attempt automatic migration of the state, use "terraform init -migrate-state".
│ If you wish to store the current configuration with no changes to the state, use "terraform init -reconfigure".

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init -reconfigure

Initializing the backend...
bucket
  The name of the S3 bucket

  Enter a value:
 Enter a value: ^C
╷
│ Error: Error asking for input to configure backend "s3": bucket: interrupted
│
│
╵

╷
│ Error: "key": required field is not set
│
│
╵

╷
│ Error: "region": required field is not set
│
│
╵

╷
│ Error: "bucket": required field is not set
│
│
╵

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~




- Verificando o help do init:

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init -h
Usage: terraform [global options] init [options]

  Initialize a new or existing Terraform working directory by creating
  initial files, loading any remote state, downloading modules, etc.

  This is the first command that should be run for any new or existing
  Terraform configuration per machine. This sets up all the local data
  necessary to run Terraform that is typically not committed to version
  control.

  This command is always safe to run multiple times. Though subsequent runs
  may give errors, this command will never delete your configuration or
  state. Even so, if you have important information, please back it up prior
  to running this command, just in case.

Options:

  -backend=false          Disable backend or Terraform Cloud initialization for
                          this configuration and use what what was previously
                          initialized instead.

                          aliases: -cloud=false

  -backend-config=path    Configuration to be merged with what is in the
                          configuration file's 'backend' block. This can be
                          either a path to an HCL file with key/value
                          assignments (same format as terraform.tfvars) or a
                          'key=value' format, and can be specified multiple
                          times. The backend type must be in the configuration
                          itself.




- Uma maneira de iniciar o backend é passando os valores via linha de comando usando o backend=true e o backend-config.

- Valores de referência:
bucket  = "tfstate-816678621138"
key     = "dev/01-usando-remote-state/terraform.tfstate"
region  = "us-east-1"
profile = "fernandomuller"

- Comando para iniciar o backend
~~~bash
terraform init -reconfigure -backend=true -backend-config="bucket=tfstate-816678621138" -backend-config="key=dev/01-usando-remote-state/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="profile=fernandomuller"
~~~


~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init -reconfigure -backend=true -backend-config="bucket=tfstate-816678621138" -backend-config="key=dev/01-usando-remote-state/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="profile=fernandomuller"

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.23.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$
~~~




- Outra maneira de fazer a inicialização do backend Remoto é via arquivo hcl.
- Criar um arquivo chamado [backend.hcl].

~~~hcl
bucket  = "tfstate-816678621138"
key     = "dev/01-usando-remote-state/terraform.tfstate"
region  = "us-east-1"
profile = "fernandomuller"
~~~

terraform init -reconfigure -backend=true -backend-config="backend.hcl"


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform init -reconfigure -backend=true -backend-config="backend.hcl"

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.23.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$



- Agora efetuar um destroy, para destruir nossa instancia EC2 e para que o state seja limpo.
~~~bash
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3
terraform destroy -auto-approve
~~~




C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula17-Remote-state-no-S3$ terraform destroy -auto-approve
aws_instance.web: Refreshing state... [id=i-0ba7d4d956a243777]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web will be destroyed
  - resource "aws_instance" "web" {
      - ami                          = "ami-04505e74c0741db8d" -> null
      - arn                          = "arn:aws:ec2:us-east-1:816678621138:instance/i-0ba7d4d956a243777" -> null
      - associate_public_ip_address  = true -> null
      - availability_zone            = "us-east-1b" -> null

Plan: 0 to add, 0 to change, 1 to destroy.
aws_instance.web: Destroying... [id=i-0ba7d4d956a243777]
aws_instance.web: Still destroying... [id=i-0ba7d4d956a243777, 10s elapsed]
aws_instance.web: Still destroying... [id=i-0ba7d4d956a243777, 20s elapsed]
aws_instance.web: Still destroying... [id=i-0ba7d4d956a243777, 30s elapsed]
aws_instance.web: Destruction complete after 33s

Destroy complete! Resources: 1 destroyed.
