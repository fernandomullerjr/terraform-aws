




- Usando o terraform console
terraform console

- Rodando o "module.website.teste_files_15_04_2022"
cd ~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules
module.website.teste_files_15_04_2022

> module.website.teste_files_15_04_2022
{
  "error.html" = {
    "file" = (known after apply)
    "object_content_type" = (known after apply)
    "object_etag" = (known after apply)
    "object_meta" = (known after apply)
  }
  "index.html" = {
    "file" = (known after apply)
    "object_content_type" = (known after apply)
    "object_etag" = (known after apply)
    "object_meta" = (known after apply)
  }
}
>





- Entendendo o files.
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/s3_module/outputs.tf

- Trazendo só a Chave, no caso a Key, deste Map "module.objects".

~~~~h
output "files" {
  value = [for filename, data in module.objects : filename]
}
~~~~

- Rodando o terraform console na raíz.

> module.website.files
[
  "error.html",
  "index.html",
]
>







- Entendendo o files.
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/s3_module/outputs.tf

- Trazendo só o Valor, no caso a Value, deste Map "module.objects".

~~~~h
output "pegando_file_path_apartir_da_raiz" {
  value = module.website.pegando_file_path
}
~~~~

- Rodando o terraform console na raíz.

> module.website.pegando_file_path
[
  (known after apply),
  (known after apply),
]
>

