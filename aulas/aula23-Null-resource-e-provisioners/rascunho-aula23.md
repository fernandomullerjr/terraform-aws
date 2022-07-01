
# 23. Null resource e provisioners

# Dia 30/06/2022

# null_resource

<https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource>

The null_resource resource implements the standard resource lifecycle but takes no further action.

The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.

- Example Usage

~~~~h
resource "aws_instance" "cluster" {
  count = 3

  # ...
}

# The primary use-case for the null resource is as a do-nothing container for
# arbitrary actions taken by a provisioner.
#
# In this example, three EC2 instances are created and then a null_resource instance
# is used to gather data about all three and execute a single action that affects
# them all. Due to the triggers map, the null_resource will be replaced each time
# the instance ids change, and thus the remote-exec provisioner will be re-run.
resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster.*.id)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = element(aws_instance.cluster.*.public_ip, 0)
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "bootstrap-cluster.sh ${join(" ", aws_instance.cluster.*.private_ip)}",
    ]
  }
}
~~~~



# Explicação
- O null_resource não toma ação alguma na infra, não altera nem nada.
- O padrão para criação é igual outros recursos, é criado declarando "resource" e definindo um nome.
- Sozinho o null_resource não tem utilidade.
- Existem triggers que permitem especificar valores arbitrários que, quando alterados, ca
- Quando combinado com os "Provisioners", algumas opções são abertas.




# ################################################################################################################################################################
# ################################################################################################################################################################
# ################################################################################################################################################################
# local-exec Provisioner

<https://www.terraform.io/language/resources/provisioners/local-exec>

- O "local-exec Provisioner" executa um comando localmente na máquina que está rodando o Terraform. Exemplo: na nossa máquina local, na máquina que está rodando o CI/CD, etc.


- Example usage

~~~~h
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
~~~~


- Por padrão o "Interpreter" utiliza o /bin/bash, mas pode ser configurado para utilizar outros.




- Criando um arquivo main.tf simples para teste, efetuando um echo simples:

~~~~h
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

resource "null_resource" "null" {
  provisioner "local-exec" {
    command = "echo Hello World"
  }
}
~~~~


- Efetuando o init, plan e apply:
terraform init
terraform plan
terraform apply

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.null will be created
  + resource "null_resource" "null" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.null: Creating...
null_resource.null: Provisioning with 'local-exec'...
null_resource.null (local-exec): Executing: ["/bin/sh" "-c" "echo Hello World"]
null_resource.null (local-exec): Hello Worl
null_resource.null: Creation complete after 0s [id=6206093357123528339]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$

~~~~




- Adicionando sinais de exclamação ao final do echo e salvando o arquivo:

~~~~h
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

resource "null_resource" "null" {
  provisioner "local-exec" {
    command = "echo Hello World!!!!!"
  }
}
~~~~


- Ao efetuar um novo apply, nada ocorre.
- Isso é devido o fato de não terem triggers configuradas, pois houve apenas uma troca no comando.

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ terraform apply --auto-approve
null_resource.null: Refreshing state... [id=6206093357123528339]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$
~~~~






# timestamp

- Examples

> timestamp()
2018-05-13T07:44:12Z


- Adicionando a trigger usando a função timestamp.
- Ela vai fazer com que o Provisioner seja triggado toda vez que for executado.

~~~~h
  triggers = {
    time = timestamp()
  }
~~~~



- Novo código com o trigger via timestamp:

~~~~h
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

resource "null_resource" "null" {
  triggers = {
    time = timestamp()
  }
  provisioner "local-exec" {
    command = "echo Hello World!!!!"
  }
}

~~~~


- Aplicando novamente:
terraform apply --auto-approve

- Resultado:

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ terraform apply --auto-approve
null_resource.null: Refreshing state... [id=6206093357123528339]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.null must be replaced
-/+ resource "null_resource" "null" {
      ~ id       = "6206093357123528339" -> (known after apply)
      + triggers = (known after apply) # forces replacement
    }

Plan: 1 to add, 0 to change, 1 to destroy.
null_resource.null: Destroying... [id=6206093357123528339]
null_resource.null: Destruction complete after 0s
null_resource.null: Creating...
null_resource.null: Provisioning with 'local-exec'...
null_resource.null (local-exec): Executing: ["/bin/sh" "-c" "echo Hello World!!!!"]
null_resource.null (local-exec): Hello World!!!!
null_resource.null: Creation complete after 0s [id=6950331281649737604]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$

~~~~









- Criando o provisioner com uma variável do tempo.

~~~~h
resource "null_resource" "null" {
  triggers = {
    time = timestamp()
  }
  provisioner "local-exec" {
     command = "echo $FOO $BAR $BAZ $TIME >> env_vars.txt"

    environment = {
      FOO = "bar"
      BAR = 1
      BAZ = "true"
      TIME = timestamp()
    }
  }
}
~~~~


- Aplicando novamente:
terraform apply --auto-approve

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ terraform apply --auto-approve
null_resource.null: Refreshing state... [id=6950331281649737604]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.null must be replaced
-/+ resource "null_resource" "null" {
      ~ id       = "6950331281649737604" -> (known after apply)
      ~ triggers = {
          - "time" = "2022-07-01T01:24:53Z"
        } -> (known after apply) # forces replacement
    }

Plan: 1 to add, 0 to change, 1 to destroy.
null_resource.null: Destroying... [id=6950331281649737604]
null_resource.null: Destruction complete after 0s
null_resource.null: Creating...
null_resource.null: Provisioning with 'local-exec'...
null_resource.null (local-exec): Executing: ["/bin/sh" "-c" "echo $FOO $BAR $BAZ $TIME >> env_vars.txt"]
null_resource.null: Creation complete after 0s [id=1020425491713034943]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$
~~~~


- Desta vez o echo não traz resultado, pois ele está gravando a saída num arquivo txt.
- No arquivo txt tem o timestamp gerado pela função timestamp.

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ cat env_vars.txt
bar 1 true 2022-07-01T01:42:20Z
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$
~~~~









- Criando um Provisioner adicional, para executar comandos do node.

~~~~h
  provisioner "local-exec" {
     command = "rm -rf nodejs-app && mkdir nodejs-app && cd nodejs-app && npm init -y && npm install joi"
  }
~~~~

- Verificando a existencia do Node:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ node -v
v10.24.0
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$
~~~~



- Aplicando novamente:
terraform apply --auto-approve

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ terraform apply --auto-approve
null_resource.null: Refreshing state... [id=1020425491713034943]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.null must be replaced
-/+ resource "null_resource" "null" {
      ~ id       = "1020425491713034943" -> (known after apply)
      ~ triggers = {
          - "time" = "2022-07-01T01:42:20Z"
        } -> (known after apply) # forces replacement
    }

Plan: 1 to add, 0 to change, 1 to destroy.
null_resource.null: Destroying... [id=1020425491713034943]
null_resource.null: Destruction complete after 0s
null_resource.null: Creating...
null_resource.null: Provisioning with 'local-exec'...
null_resource.null (local-exec): Executing: ["/bin/sh" "-c" "echo $FOO $BAR $BAZ $TIME >> env_vars.txt"]
null_resource.null: Provisioning with 'local-exec'...
null_resource.null (local-exec): Executing: ["/bin/sh" "-c" "rm -rf nodejs-app && mkdir nodejs-app && cd nodejs-app && npm init -y && npm install joi"]
null_resource.null (local-exec): npm WARN npm npm does not support Node.js v10.24.0
null_resource.null (local-exec): npm WARN npm You should probably upgrade to a newer version of node as we
null_resource.null (local-exec): npm WARN npm can't make any promises that npm will work with this version.
null_resource.null (local-exec): npm WARN npm Supported releases of Node.js are the latest release of 4, 6, 7, 8, 9.
null_resource.null (local-exec): npm WARN npm You can find the latest version at https://nodejs.org/
null_resource.null (local-exec): Wrote to /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners/nodejs-app/package.json:

null_resource.null (local-exec): {
null_resource.null (local-exec):   "name": "nodejs-app",
null_resource.null (local-exec):   "version": "1.0.0",
null_resource.null (local-exec):   "description": "",
null_resource.null (local-exec):   "main": "index.js",
null_resource.null (local-exec):   "scripts": {
null_resource.null (local-exec):     "test": "echo \"Error: no test specified\" && exit 1"
null_resource.null (local-exec):   },
null_resource.null (local-exec):   "keywords": [],
null_resource.null (local-exec):   "author": "",
null_resource.null (local-exec):   "license": "ISC"
null_resource.null (local-exec): }


null_resource.null (local-exec): npm WARN npm npm does not support Node.js v10.24.0
null_resource.null (local-exec): npm WARN npm You should probably upgrade to a newer version of node as we
null_resource.null (local-exec): npm WARN npm can't make any promises that npm will work with this version.
null_resource.null (local-exec): npm WARN npm Supported releases of Node.js are the latest release of 4, 6, 7, 8, 9.
null_resource.null (local-exec): npm WARN npm You can find the latest version at https://nodejs.org/
null_resource.null (local-exec): npm notice created a lockfile as package-lock.json. You should commit this file.
null_resource.null (local-exec): npm WARN nodejs-app@1.0.0 No description
null_resource.null (local-exec): npm WARN nodejs-app@1.0.0 No repository field.

null_resource.null (local-exec): + joi@17.6.0
null_resource.null (local-exec): added 6 packages in 2.363s
null_resource.null: Creation complete after 5s [id=1672248509792392615]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ ls
env_vars.txt  main.tf  nodejs-app  rascunho-aula23.md  terraform.tfstate  terraform.tfstate.backup
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$ ls nodejs-app/
node_modules  package.json  package-lock.json
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula23-Null-resource-e-provisioners$
~~~~






# IMPORTANTE
Important: Use provisioners as a last resort. There are better alternatives for most situations. Refer to Declaring Provisioners for more details.
Os Provisioners são considerados como última alternativa.
Existem alternativas melhores com recursos nativos do Terraform ou não, para evitar o uso dos Provisioners.





- Criando o arquivo main.tf na versão final:

~~~~h
terraform {
  required_version = "1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

resource "null_resource" "null" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = "echo $FOO $BAR $BAZ $TIME >> env_vars.txt"

    environment = {
      FOO = "bar"
      BAR = 1
      BAZ = "true"
      TIME = timestamp()
    }
  }

  provisioner "local-exec" {
    command = "rm -rf nodejs-app && mkdir nodejs-app && cd nodejs-app && npm init -y && npm install joi"
  }
}
~~~~