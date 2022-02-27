


# Instalando o TFenv

- Comando para mudar a versão do Terraform:

tfenv use [versão-desejada]

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ tfenv use
Switching default version to v1.1.5
Switching completed
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$
~~~



# Verificando a versão do Terraform:

- É possível verificar a versão do Terraform usando os comandos:

~~~bash
tfenv list
terraform version
cat /home/fernando/.tfenv/version
~~~

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ tfenv list
* 1.1.5 (set by /home/fernando/.tfenv/version)
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ terraform version
Terraform v1.1.5
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.1.6. You can update by downloading from https://www.terraform.io/downloads.html
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ cat /home/fernando/.tfenv/version
1.1.5
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$
~~~





