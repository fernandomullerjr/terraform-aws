



# ##################################################################################################################################################
# DUVIDA 1

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











# ##################################################################################################################################################
#  DUVIDA 2 - 

- A função fileset recebe um caminho, que está sendo passado aqui, na raíz:
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/main.tf
    files = "${path.root}/website"

- E retorna um array com os arquivos encontrados conforme o pattern:
    (fileset(var.files, "**") -> pattern **
quer dizer qualquer arquivo, incluindo subdiretórios) que é passado.

- No caso do módulo, eu estou passando para ele o caminho onde estão os arquivos do website (files = "${path.root}/website") e a função fileset vai retornar um array com dois arquivos:

[
  "website/index.html",
  "website/error.html"
]

- Dentro do s3_module ele vai iterar sobre esses dois arquivos e criar dois recursos do tipo bucket object com os respectivos arquivos dentro do diretório website (index.html e error.html).
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/s3_module/main.tf
    for_each = var.files != "" ? fileset(var.files, "**") : []











# DUVIDA nova

Oi Cleber, boa tarde.

Primeiro, muito obrigado, teus esclarecimentos ajudaram demais, esse segundo esclareceu 99% das dúvidas.
Mas como você disse para avisar se não ficar claro algo, só tem 1 detalhe que fiquei na dúvida ainda.

Na estrutura do projeto, vem a raíz e depois as pastas s3_module e s3_object.

├── main.tf
├── outputs.tf
├── s3_module
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.MD
│   ├── s3_object
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── variables.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── website
    ├── error.html
    └── index.html

Só não entendi como a var.files tem o valor do campo files lá da raíz, visto que o var.files é usado dentro do main.tf da pasta s3_module.
Seria pelo fato do main.tf chamar o módulo da s3_module através do source = "./s3_module" ?
Porque no meu entendimento, o var.files no main.tf do s3_module seria o valor da variável dentro do arquivo variables.tf no mesmo escopo/pasta do main.tf do s3_module.
No mais, obrigado mais uma vez pela tua ajuda, só restou esta pequena dúvida mesmo, porque os conceitos dos módulos deram uma confundida na cabeça mesmo.
Abraço.







# ##################################################################################################################################################
# Fernando - detalhando - entendimento sobre a variável na raíz, duvida2/duvida-nova

- Esse campo name da raíz na declaração do módulo "website", tem relação direta com o s3_module.
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/main.tf

~~~~h
module "website" {
  source = "./s3_module"

  name  = random_pet.website.id
~~~~

Obs:
Esse conteúdo acima já é o suficiente para criar o nosso módulo.

- Importante!
- Importante!
- Este "name" informado no module website na raíz, está diretamente ligado a variável "var.name" do arquivo main.tf do s3_module:

~~~~h
resource "aws_s3_bucket" "this" {
  bucket = var.name
~~~~

- Apesar de ter a var.name, no arquivo variables.tf a variável name tem um valor vazio.
- Esse valor da variável name é populado com o valor do campo name do módulo website na raíz.

~~~~h
variable "name" {
  type        = string
  description = "Bucket name"
}
~~~~




- Mais detalhes:
<https://stackoverflow.com/questions/67160077/reusing-variables-declared-and-defined-in-parent-module-in-terraform>
Explicando sobre a herança de variáveis entre os módulos, raíz e filho:
Modules do not inherit variables from the parent module. All modules are self-contained units. So you have to explicitly define variables in the child module, and then explicit set these variables in the parent module, when you instantiate the child module.
