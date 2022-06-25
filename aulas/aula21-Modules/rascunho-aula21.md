
# Aula 21. Modules

- Criando arquivos da aula, com base no repositório:
<https://github.com/chgasparoto/curso-aws-com-terraform/tree/master/02-terraform-intermediario/05-modules>

- Para declarar um módulo, chamamos o "module" e definimos um nome para ele(bucket), isso no main.tf principal da raíz.
- Também definimos o nome do Bucket com o campo "name", pois o campo name não tem um valor default no variables.tf do módulo s3_module.
- Trecho do arquivo main.tf da raíz do projeto:

~~~hcl
module "bucket" {
  source = "./s3_module"
  name   = random_pet.this.id

  versioning = {
    enabled = true
  }
}
~~~

- Arquivo variables.tf não tem um valor default para o "name", por isso precisamos definir um valor via random_pet anteriormente:

~~~hcl
variable "name" {
  type        = string
  description = "Bucket name"
}

variable "acl" {
  type        = string
  description = ""
  default     = "private"
}

variable "policy" {
  type        = string
  description = ""
  default     = null
}
~~~



- Rodando o terraform init, para iniciar o projeto.
terraform init

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform init
Initializing modules...
- bucket in s3_module
- bucket.objects in s3_module/s3_object
- website in s3_module
- website.objects in s3_module/s3_object

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.23.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/aws v3.23.0...
- Installed hashicorp/aws v3.23.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.2...
- Installed hashicorp/random v3.1.2 (signed by HashiCorp)

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
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~


- Após executar o terraform init, ele cria uma pasta oculta chamada ".terraform", dentro dela temos a pasta "modules".
- No arquivo "modules.json" temos o mapeamento de módulos no projeto.

~~~json
{
    "Modules": [
        {
            "Key": "",
            "Source": "",
            "Dir": "."
        },
        {
            "Key": "bucket",
            "Source": "./s3_module",
            "Dir": "s3_module"
        },
        {
            "Key": "bucket.objects",
            "Source": "./s3_object",
            "Dir": "s3_module/s3_object"
        },
        {
            "Key": "website",
            "Source": "./s3_module",
            "Dir": "s3_module"
        },
        {
            "Key": "website.objects",
            "Source": "./s3_object",
            "Dir": "s3_module/s3_object"
        }
    ]
}
~~~



- Efetuar o terraform plan para verificar o que vai ser criado:
terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.bucket.aws_s3_bucket.this will be created
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
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects["error.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "a079b6818095cae21bf0d42a9369c0a6"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/error.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/error.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects["index.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "52d363c05c4a68ceaa5a3d934a89be97"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn           = (known after apply)
  + bucket-name          = (known after apply)
  + bucket-website-arn   = (known after apply)
  + bucket-website-files = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name  = (known after apply)
  + bucket-website-url   = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~




- Efetuar o apply
terraform apply -auto-approve

~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.bucket.aws_s3_bucket.this will be created
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
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects["error.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "a079b6818095cae21bf0d42a9369c0a6"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/error.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/error.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects["index.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "52d363c05c4a68ceaa5a3d934a89be97"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn           = (known after apply)
  + bucket-name          = (known after apply)
  + bucket-website-arn   = (known after apply)
  + bucket-website-files = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name  = (known after apply)
  + bucket-website-url   = (known after apply)
random_pet.website: Creating...
random_pet.this: Creating...
random_pet.this: Creation complete after 0s [id=hugely-solely-eagerly-large-rodent]
random_pet.website: Creation complete after 0s [id=overly-preferably-happily-lucky-warthog]
module.bucket.aws_s3_bucket.this: Creating...
module.website.aws_s3_bucket.this: Creating...
module.bucket.aws_s3_bucket.this: Still creating... [10s elapsed]
module.website.aws_s3_bucket.this: Still creating... [10s elapsed]
module.bucket.aws_s3_bucket.this: Creation complete after 12s [id=hugely-solely-eagerly-large-rodent]
module.website.aws_s3_bucket.this: Creation complete after 13s [id=overly-preferably-happily-lucky-warthog]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/index.html]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket-arn = "arn:aws:s3:::hugely-solely-eagerly-large-rodent"
bucket-name = "hugely-solely-eagerly-large-rodent"
bucket-website-arn = "arn:aws:s3:::overly-preferably-happily-lucky-warthog"
bucket-website-files = [
  "error.html",
  "index.html",
]
bucket-website-name = "overly-preferably-happily-lucky-warthog"
bucket-website-url = "overly-preferably-happily-lucky-warthog.s3-website-us-east-1.amazonaws.com"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~



# Website

- Na nossa pasta "website" temos 2 arquivos:
  error.html
  index.html
Estes 2 arquivos são usados na criação do site estático no bucket do S3.

- Usaremos o recurso "s3_bucket" do Terraform:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>

- Static Website Hosting
NOTE:
  The parameter website is deprecated. Use the resource aws_s3_bucket_website_configuration instead.
  O site do Terraform indica que a criação do parametro website está depreciada e indica o uso do recurso "aws_s3_bucket_website_configuration" no lugar dele.
  <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration>
  - Forma depreciada, indicada pelo site do "s3_bucket":

~~~hcl
resource "aws_s3_bucket" "b" {
  bucket = "s3-website-test.hashicorp.com"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}
~~~


- Exemplo usando a nova versão.
- Resource: aws_s3_bucket_website_configuration
    Provides an S3 bucket website configuration resource. For more information, see Hosting Websites on S3.

- Example Usage
~~~hcl
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
~~~


- Nos 2 exemplos são mostradas as "routing_rule", mas não iremos usar elas.
- Iremos usar o "website".


- Exemplo editado do "main.tf" de dentro do s3_module, como ficaria se fossemos usar o módulo original:

~~~hcl
resource "aws_s3_bucket" "this" {
  bucket = "s3-website-test.hashicorp.com"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
~~~



# Dynamic Blocks
<https://www.terraform.io/language/expressions/dynamic-blocks>
- Se formos tentar aplicar isto, ao tentar criar o bucket do "main.tf" da raíz, ele vai tentar alterar o Bucket do S3 e colocar a parte de Website nele, mesmo que a gente queira criar um Bucket simples. Para resolver isto, podemos usar no módulo do S3 uma feature do Terraform que é o "Dynamic Blocks".
Usando o "Dynamic Blocks" passamos uma condição para o Terraform criar aquele recurso, dependendo da condição ele faz uma coisa.


- Como o for_each pode substituir o count, eles tem funcionalidades parecidas.
- No nosso caso vamos usar o for_each, pois podemos acessar informações especificas da nossa lista.
- Iremos criar no "variables.tf" do s3_module uma variável do tipo Map, com valores em string, a variável será chamada "website". Ela vai ser iniciada com valor default vazio.
  aulas/aula21-Modules/s3_module/variables.tf

~~~hcl
variable "website" {
  description = "Map containing website configuration."
  type        = map(string)
  default     = {}
}
~~~

-


# Função Keys

keys(var.website)
  "A função ""keys"" retorna as chaves.
  No nosso caso a função ""keys"" retorna a lista de chaves da variável do tipo Map.


# Explicando melhor sobre o for_each do Website, dentro do módulo S3_MODULE

- Abrindo o arquivo main.tf do S3_MODULE:
  /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/s3_module/main.tf
- Iremos iterar usando o for_each.
  ato de iterar (repetir) uma função por um determinado período de tempo até que uma condição seja alcançada. 
  Iteração é o processo chamado na programação de repetição de uma ou mais ações. É importante salientar que cada iteração se refere a apenas uma instância da ação, ou seja, cada repetição possui uma ou mais iterações.
- No nosso caso a função ""keys"" retorna a lista de chaves da variável do tipo Map.
- A função "length" vai retornar a quantidade de chaves que a função "keys" retornou.
- Se o valor for zerado, o retorno vai ser um Array vazio.
- Caso o valor não seja zerado, vai retorna uma lista de 1 elemento, no caso a variável "website".
~~~~h
  for_each = length(keys(var.website)) == 0 ? [] : [var.website]
~~~~

- Iremos acessar cada valor de dentro da nossa variável usando a função lookup.
- O for_each está jogando os valores dentro do dynamic "website".
Podemos acessar os valores das chaves e valores usando:
  website.key
  website.value
E assim por diante.
- Num bloco dinâmico, acessamos os valores com o nome que a gente definiu.
- Acessando o valor do index_document:
  index_document           = lookup(website.value, "index_document", null)

- Nosso bloco de código para o Dynamic ficará assim, no main.tf do Module S3:
  /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules/s3_module/main.tf

~~~h
resource "aws_s3_bucket" "this" {
  bucket = var.name
  acl    = var.acl
  policy = var.policy
  tags   = var.tags

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]
    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }
~~~




- Seguindo com as configurações, agora no main.tf da raíz.
- Temos a criação do recurso random_pet, chamado "website", para definir um nome para o bucket do Website.
- Usamos o Módulo Website, criamos o bloco website, definindo os valores para index_document e error_document.
- Precisamos criar uma Policy para o nosso bucket ficar acessível publicamente.

~~~hcl
resource "random_pet" "website" {
  length = 5
}

module "website" {
  source = "./s3_module"

  name  = random_pet.website.id
  acl   = "public-read"
  files = "${path.root}/website"

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${random_pet.website.id}/*"
            ]
        }
    ]
}
EOT
}
~~~


- Mesmo sendo um mesmo módulo que foi usado na criação do Bucket normal, precisamos rodar um Terraform init para que seja iniciado o módulo s3_module para o Website.
- No estado atual, se for feito o apply e criar os recursos, o site não estará acessível, pois não foram criados os objetos com as páginas de index e de error.




# Criando objetos

- Para poder subir as páginas para o bucket, iremos criar um módulo de objetos.
- Criar uma pasta chamada "s3_object" dentro da pasta "s3_module".
  mkdir material-do-curso/curso-aws-com-terraform-master/02-terraform-intermediario/05-modules/s3_module/s3_object
- Iremos criar 3 arquivos do Terraform:
  main.tf
  variables.tf
  outputs.tf
- O arquivo de variáveis tem 


No arquivo main.tf
setar o Content Type corretamente, usando a função lookup:
~~~~h
  content_type = lookup(var.file_types, regex("\\.[^\\.]+\\z", var.src), var.default_file_type)
~~~~


- Exemplo do variables.tf que o lookup do Content Type varre, apenas um trecho:

~~~h
variable "file_types" {
  description = "Map from file suffixes, which must begin with a period and contain no periods, to the corresponding Content-Type values."

  type = map(string)
  default = {
    ".txt"    = "text/plain; charset=utf-8"
    ".html"   = "text/html; charset=utf-8"
    ".htm"    = "text/html; charset=utf-8"
~~~


# LOOKUP function
- Reforçando um pouco sobre a função lookup:
lookup retrieves the value of a single element from a map, given its key. If the given key does not exist, the given default value is returned instead.
Example:
  lookup(map, key, default)
- Este exemplo abaixo procura o valor de "a" no "map", como ele existe, retorna o valor da "key" fornecida.
> lookup({a=""ay"", b=""bee""}, ""a"", ""what?"")
ay



# REGEX function
<https://www.terraform.io/language/functions/regex>

~~~~h
resource "aws_s3_bucket_object" "this" {
  bucket       = var.bucket
  key          = var.key
  source       = var.src
  etag         = filemd5(var.src)
  content_type = lookup(var.file_types, regex("\\.[^\\.]+\\z", var.src), var.default_file_type)
}
~~~~


- O módulo do objeto vai ficar assim:

- Arquivo main.tf

~~~h
resource "aws_s3_bucket_object" "this" {
  bucket       = var.bucket
  key          = var.key
  source       = var.src
  etag         = filemd5(var.src)
  content_type = lookup(var.file_types, regex("\\.[^\\.]+\\z", var.src), var.default_file_type)
}
~~~


- Arquivo variables.tf

~~~h
variable "bucket" {}
variable "key" {}
variable "src" {}

# https://github.com/hashicorp/terraform-template-dir/blob/master/variables.tf
variable "file_types" {
  description = "Map from file suffixes, which must begin with a period and contain no periods, to the corresponding Content-Type values."

  type = map(string)
  default = {
    ".txt"    = "text/plain; charset=utf-8"
    ".html"   = "text/html; charset=utf-8"
[.....................................................]
    ".woff2"  = "font/woff2"
  }
}

variable "default_file_type" {
  type        = string
  default     = "application/octet-stream"
  description = "The Content-Type value to use for any files that don't match one of the suffixes given in file_types."
}

~~~





- Arquivo outputs.tf

~~~hcl
output "file" {
  value = "${var.bucket}${aws_s3_bucket_object.this.key}"
}

output "object_etag" {
  value = aws_s3_bucket_object.this.etag
}

output "object_content_type" {
  value = aws_s3_bucket_object.this.content_type
}

output "object_meta" {
  value = aws_s3_bucket_object.this.metadata
}
~~~





- De volta no módulo do s3_module.
- Iremos usar um for_each para efetuar upload de + de 1 objeto por vez.
- Se não é usado o for_each, temos que usar vários object toda vez.
- Passando uma lista via for_each, podemos enviar vários arquivos para o S3 de uma só vez.
- Usaremos a função fileset.


# fileset Function

<https://www.terraform.io/language/functions/fileset>

fileset enumerates a set of regular file names given a path and pattern. The path is automatically removed from the resulting set of file names and any result still containing path separators always returns forward slash (/) as the path separator for cross-system compatibility.
    fileset(path, pattern)

- No nosso for_each, verificamos:
  Se a variável files for diferente de vazio, execute o fileset
~~~~h
    for_each = var.files != "" ? fileset(var.files, "**") : []
~~~~

- Explicando o uso dos padrões de combinações na função "fileset":
  ** - matches any sequence of characters, including separator characters


- Variável "files" no arquivo variables.tf do S3_MODULE:

~~~h
variable "files" {
  type    = string
  default = ""
}
~~~


- O módulo dos Objetos no arquivo main.tf do S3_MODULE:

~~~~h
module "objects" {
  source = "./s3_object"

  for_each = var.files != "" ? fileset(var.files, "**") : []

  bucket = aws_s3_bucket.this.bucket
  key    = "${var.key_prefix}/${each.value}"
  src    = "${var.files}/${each.value}"
}
~~~~



# PENDENTE
- Entender melhor como o valor da variável "var.files" é populado.
- Detalhar o for_each.

- Continuando aula em 15:05m
- Continuando aula em 15:05m
- Continuando aula em 15:05m

- O for_each vai fazer uma varredura.
- O retorno desta varredura será usado no "each.value" informado no "src".
- No for_each é verificado uma lista de arquivos que a gente queira subir para o Bucket do S3.
- Se a variável "var.files" for diferente de vazio, ele vai usar a função "Fileset". Ela varre um diretório, conforme a expressão que é passada, retornando uma lista de arquivos que existem dentro deste diretório. Os 2 asteriscos ** varrem pasta por pasta de forma recursiva.
    fileset(path, pattern)
- São criadas as 2 variaveis "var.key_prefix" e "var.files" no arquivo variables.tf do tipo String, mas elas não são obrigatórias.

~~~h
module "objects" {
  source = "./s3_object"

  for_each = var.files != "" ? fileset(var.files, "**") : []

  bucket = aws_s3_bucket.this.bucket
  key    = "${var.key_prefix}/${each.value}"
  src    = "${var.files}/${each.value}"
}
~~~





- Voltar para a raíz do projeto.
- Criar um arquivo contendo os outputs:
outputs.tf

~~~hcl
output "bucket-name" {
  value = module.bucket.name
}

output "bucket-arn" {
  value = module.bucket.arn
}

output "bucket-website-name" {
  value = module.website.name
}

output "bucket-website-url" {
  value = module.website.website
}

output "bucket-website-arn" {
  value = module.website.arn
}

output "bucket-website-files" {
  value = module.website.files
}
~~~




- Validar se tudo está ok.
- USar o comando terraform fmt -recursive, para formatar tudo de forma recursiva
- Rodar o terraform init para iniciar os módulos criados.
- Rodar um terraform validate, para conferir se tudo está ok.
terraform fmt -recursive
terraform init
terraform validate

~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform fmt -recursive
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/aws v3.23.0
- Using previously-installed hashicorp/random v3.1.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~




files = "${path.root}/website"
Indicando o caminho da nossa raíz, usando a referencia "path.root".
Desta forma, o Módulo Website vai ler todos os arquivos contidos na pasta Website.







terraform plan

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn           = (known after apply)
  + bucket-name          = (known after apply)
  + bucket-website-arn   = (known after apply)
  + bucket-website-files = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name  = (known after apply)
  + bucket-website-url   = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ ^C
~~~




terraform apply -auto-approve

~~~bash
random_pet.this: Creating...
random_pet.website: Creating...
random_pet.this: Creation complete after 0s [id=hardly-sadly-lightly-mature-jay]
random_pet.website: Creation complete after 0s [id=unlikely-highly-frequently-liberal-sturgeon]
module.bucket.aws_s3_bucket.this: Creating...
module.website.aws_s3_bucket.this: Creating...
module.bucket.aws_s3_bucket.this: Still creating... [10s elapsed]
module.website.aws_s3_bucket.this: Still creating... [10s elapsed]
module.bucket.aws_s3_bucket.this: Creation complete after 11s [id=hardly-sadly-lightly-mature-jay]
module.website.aws_s3_bucket.this: Creation complete after 12s [id=unlikely-highly-frequently-liberal-sturgeon]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/index.html]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket-arn = "arn:aws:s3:::hardly-sadly-lightly-mature-jay"
bucket-name = "hardly-sadly-lightly-mature-jay"
bucket-website-arn = "arn:aws:s3:::unlikely-highly-frequently-liberal-sturgeon"
bucket-website-files = [
  "error.html",
  "index.html",
]
bucket-website-name = "unlikely-highly-frequently-liberal-sturgeon"
bucket-website-url = "unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~





- Após aplicados os recursos é possível acessar os endpoints da página principal e da página de erro
  <http://unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com/>
  <http://unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com/error.html>



unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com
curl unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com

~~~html
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ curl unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Index page</title>
</head>
<body>
<h1>Index page</h1>
</body>
</html>
~~~


fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$





http://unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com/error.html

curl http://unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com/error.html

~~~html
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ curl http://unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com/error.html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Error page</title>
</head>
<body>
<h1>Error page</h1>
</body>
</html>
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~









# PENDENTE
- Entender melhor como o valor da variável "var.files" é populado. Que é citado no video por volta de 15min a 20min de aula.
verificar retorno sobre a pergunta realizada no Udemy para o Cleber:
<https://www.udemy.com/course/aws-com-terraform/learn/lecture/25939380#questions/17304468>
- Detalhar o for_each.


aulas/aula21-Modules/s3_module/main.tf
~~~h
  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]
    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }
}
~~~


aulas/aula21-Modules/s3_module/variables.tf
~~~h
variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}
~~~



aulas/aula21-Modules/main.tf
~~~h
module "bucket" {
  source = "./s3_module"
  name   = random_pet.this.id

  versioning = {
    enabled = true
  }
}
~~~






# ##################################################################################################################################################
# ##################################################################################################################################################
# Testando como o Terraform traz os valores dos outputs dos files.

- Arquivo de Outputs do Módulo s3_module:
aulas/aula21-Modules/s3_module/outputs.tf

~~~hcl
output "teste_files_15_04_2022" {
  value = module.objects
}
~~~


- Editando o arquivo outputs da raíz do projeto:
aulas/aula21-Modules/outputs.tf

~~~hcl
output "teste_files_15_04_2022_da_raiz" {
  value = module.website.teste_files_15_04_2022
}
~~~


- Efetuando o plan, é possível verificar que o output de teste traz os dados "brutos", sem filtrar pelo filename:
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform plan
random_pet.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
random_pet.website: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
module.bucket.aws_s3_bucket.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
module.website.aws_s3_bucket.this: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Refreshing state... [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Refreshing state... [id=/index.html]

Changes to Outputs:
  + teste_files_15_04_2022_da_raiz = {
      + error.html = {
          + file                = "unlikely-highly-frequently-liberal-sturgeon/error.html"
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "a079b6818095cae21bf0d42a9369c0a6"
          + object_meta         = {}
        }
      + index.html = {
          + file                = "unlikely-highly-frequently-liberal-sturgeon/index.html"
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "52d363c05c4a68ceaa5a3d934a89be97"
          + object_meta         = {}
        }
    }

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~






~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform apply -auto-approve
random_pet.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
random_pet.website: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
module.bucket.aws_s3_bucket.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
module.website.aws_s3_bucket.this: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Refreshing state... [id=/index.html]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Refreshing state... [id=/error.html]

Changes to Outputs:
  + teste_files_15_04_2022_da_raiz = {
      + error.html = {
          + file                = "unlikely-highly-frequently-liberal-sturgeon/error.html"
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "a079b6818095cae21bf0d42a9369c0a6"
          + object_meta         = {}
        }
      + index.html = {
          + file                = "unlikely-highly-frequently-liberal-sturgeon/index.html"
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "52d363c05c4a68ceaa5a3d934a89be97"
          + object_meta         = {}
        }
    }

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bucket-arn = "arn:aws:s3:::hardly-sadly-lightly-mature-jay"
bucket-name = "hardly-sadly-lightly-mature-jay"
bucket-website-arn = "arn:aws:s3:::unlikely-highly-frequently-liberal-sturgeon"
bucket-website-files = [
  "error.html",
  "index.html",
]
bucket-website-name = "unlikely-highly-frequently-liberal-sturgeon"
bucket-website-url = "unlikely-highly-frequently-liberal-sturgeon.s3-website-us-east-1.amazonaws.com"
teste_files_15_04_2022_da_raiz = {
  "error.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/error.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "a079b6818095cae21bf0d42a9369c0a6"
    "object_meta" = tomap({})
  }
  "index.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/index.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "52d363c05c4a68ceaa5a3d934a89be97"
    "object_meta" = tomap({})
  }
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~



- Usando o comando "terraform output" para trazer o output especifico de um Output desejado:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ ^C
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform output teste_files_15_04_2022_da_raiz
{
  "error.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/error.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "a079b6818095cae21bf0d42a9369c0a6"
    "object_meta" = tomap({})
  }
  "index.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/index.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "52d363c05c4a68ceaa5a3d934a89be97"
    "object_meta" = tomap({})
  }
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~





- Explicando a expressão for do files.

~~~hcl
output "files" {
  value = [for filename, data in module.objects : filename]
}
~~~

Acessamos os valores do módulo "objects", pegando filename(key) e o data(value).
Ao final, após os 2 pontos, informamos o que queremos trazer apenas, que no caso é o filename(key/chave).
Assim, ele traz uma lista mais sucinta dos arquivos.

exemplo:

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform output bucket-website-files
[
  "error.html",
  "index.html",
]
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~

Que é o resultado do output do módulo s3_module:
~~~h
output "files" {
  value = [for filename, data in module.objects : filename]
}
~~~

Que é acessado pela raíz via output:
~~~h
output "bucket-website-files" {
  value = module.website.files
}
~~~









~~~h
module "bucket" {
  source = "./s3_module"
  name   = random_pet.this.id

  versioning = {
    enabled = true
  }
}
~~~

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform output bucket-name
"hardly-sadly-lightly-mature-jay"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform output bucket-website-name
"unlikely-highly-frequently-liberal-sturgeon"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~




27min de aula


~~~h
resource "aws_s3_bucket" "this" {
  bucket = var.name
  acl    = var.acl
  policy = var.policy
  tags   = var.tags
~~~


- Se a variável não for obrigatória, ela precisa ter um valor default, mesmo que seja um valor vazio.
- Se a variável for obrigatória, ela não pode ter um valor default. Então toda vez que a variável for passada, ela precisa de um valor.

- Nos Outputs setamos valores que desejamos usar fora do módulo.









# Teste
explicando melhor as Chaves e Valores e como acessar elas.
~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform output teste_files_15_04_2022_da_raiz
{
  "error.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/error.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "a079b6818095cae21bf0d42a9369c0a6"
    "object_meta" = tomap({})
  }
  "index.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/index.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "52d363c05c4a68ceaa5a3d934a89be97"
    "object_meta" = tomap({})
  }
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~







- Testando
tentando colocar um output no s3_module para o output file do s3_object
~~~h
output "teste_apenas_file" {
  value = module.objects.file
}
~~~

terraform console
module.website.teste_files_15_04_2022

terraform console
module.website.teste_apenas_file


- Apresentou erro:

~~~bash
│ Error: Unsupported attribute
│
│   on s3_module/outputs.tf line 39, in output "teste_apenas_file":
│   39:   value = module.objects.file
│     ├────────────────
│     │ module.objects is object with no attributes
│
│ This object does not have an attribute named "file".
╵
╷
│ Error: Unsupported attribute
│
│   on s3_module/outputs.tf line 39, in output "teste_apenas_file":
│   39:   value = module.objects.file
│     ├────────────────
│     │ module.objects is object with 2 attributes
│
│ This object does not have an attribute named "file".
╵
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~



Acessando os valores de um Map e buscando o ARN das instancias EC2.
 [for k, v in aws_instance.this : v.arn]

Output esperado:

~~~h
instance_arns = [
  ""arn:aws:ec2:us-east-1:816678621138:instance/i-080275a5f2fd475a2"",
  ""arn:aws:ec2:us-east-1:816678621138:instance/i-0cb0a3d60de140645"",
]"	
~~~


{
  "error.html" = {
    "file" = "unlikely-highly-frequently-liberal-sturgeon/error.html"


output "pegando_file_path" {
  value = [for k, v in module.objects : v.file]
}



- Criando no arquivo de outputs do módulo s3_module:
aulas/aula21-Modules/s3_module/outputs.tf

~~~h
output "pegando_file_path" {
  value = [for k, v in module.objects : v.file]
}
~~~


- Criando na raíz:
aulas/aula21-Modules/outputs.tf

~~~h
output "pegando_file_path_da_raiz" {
  value = module.website.pegando_file_path
}
~~~


-Efetuando plan para testar:
  trouxe os valores das chaves dos objetos, que foram acessadas, no caso os valores/value das chaves/keys "file".

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform plan
random_pet.website: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
random_pet.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
module.website.aws_s3_bucket.this: Refreshing state... [id=unlikely-highly-frequently-liberal-sturgeon]
module.bucket.aws_s3_bucket.this: Refreshing state... [id=hardly-sadly-lightly-mature-jay]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Refreshing state... [id=/index.html]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Refreshing state... [id=/error.html]

Changes to Outputs:
  + pegando_file_path_apartir_da_raiz = [
      + "unlikely-highly-frequently-liberal-sturgeon/error.html",
      + "unlikely-highly-frequently-liberal-sturgeon/index.html",
    ]

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~




terraform destroy -auto-approve

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform destroy -auto-approve
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Destroying... [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Destroying... [id=/index.html]
module.bucket.aws_s3_bucket.this: Destroying... [id=hardly-sadly-lightly-mature-jay]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Destruction complete after 1s
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Destruction complete after 1s
module.website.aws_s3_bucket.this: Destroying... [id=unlikely-highly-frequently-liberal-sturgeon]
module.bucket.aws_s3_bucket.this: Destruction complete after 1s
random_pet.this: Destroying... [id=hardly-sadly-lightly-mature-jay]
random_pet.this: Destruction complete after 0s
module.website.aws_s3_bucket.this: Destruction complete after 0s
random_pet.website: Destroying... [id=unlikely-highly-frequently-liberal-sturgeon]
random_pet.website: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$
~~~





# PENDENTE
- Entender melhor como o valor da variável "var.files" é populado. Que é citado no video por volta de 15min a 20min de aula. Não encontrei onde o valor dela é definido. É o valor vazio/null mesmo, setado no default?
    aulas/aula21-Modules/s3_module/main.tf
- Ver também sobre a variável "key_prefix", não encontrei onde o valor dela é definido. É o valor vazio/null mesmo, setado no default?
- Verificar retorno sobre a pergunta realizada no Udemy para o Cleber:
    <https://www.udemy.com/course/aws-com-terraform/learn/lecture/25939380#questions/17304468>
- Detalhar o for_each.
- Tentar criar um output que traga o valor da var.files, para entender o que ela coloca exatamente.

- Video continua em 11:58m, repasando os pontos novamente.
- Abrir explicações no word "Explicando-melhor-for-each-funcoes-dynamic-etc"
- Continuar na linha 1055.


# Dia 19/06/2022
- Recapitulando os tópicos.
- Ver resposta do Cleber.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ history | tail
  505  git status
  506  git status
  507  git remote -v
  508  eval $(ssh-agent -s)
  509  ssh-add /home/fernando/.ssh/chave-debian10-github
  510  git status
  511  git add .
  512  git commit -m "Aula 21 - modules - detalhando o for_each e fileset."
  513  git push
  514  history | tail
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$


- Continuar na linha 1055.






# Dia 25/06/2022
Exemplo:
~~~~h
module.objects = {
  "meu_site/index.html" = {
   // aqui vai os outputs do módulo
  },
  "meu_site/error.html" = {
   // aqui vai os outputs do módulo
  },
}
~~~~




- Efetuado um apply para verificar os Outputs e os valores dos Outputs de teste:

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ pwd
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.this will be created
  + resource "random_pet" "this" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.bucket.aws_s3_bucket.this will be created
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
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects["error.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "a079b6818095cae21bf0d42a9369c0a6"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/error.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/error.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects["index.html"].aws_s3_bucket_object.this will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "52d363c05c4a68ceaa5a3d934a89be97"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "/index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./website/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket-arn                        = (known after apply)
  + bucket-name                       = (known after apply)
  + bucket-website-arn                = (known after apply)
  + bucket-website-files              = [
      + "error.html",
      + "index.html",
    ]
  + bucket-website-name               = (known after apply)
  + bucket-website-url                = (known after apply)
  + pegando_file_path_apartir_da_raiz = [
      + (known after apply),
      + (known after apply),
    ]
  + teste_files_15_04_2022_da_raiz    = {
      + error.html = {
          + file                = (known after apply)
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "a079b6818095cae21bf0d42a9369c0a6"
          + object_meta         = null
        }
      + index.html = {
          + file                = (known after apply)
          + object_content_type = "text/html; charset=utf-8"
          + object_etag         = "52d363c05c4a68ceaa5a3d934a89be97"
          + object_meta         = null
        }
    }
random_pet.website: Creating...
random_pet.this: Creating...
random_pet.website: Creation complete after 0s [id=deadly-privately-pleasantly-uncommon-ox]
random_pet.this: Creation complete after 0s [id=vertically-supposedly-morally-actual-escargot]
module.website.aws_s3_bucket.this: Creating...
module.bucket.aws_s3_bucket.this: Creating...
module.bucket.aws_s3_bucket.this: Still creating... [10s elapsed]
module.website.aws_s3_bucket.this: Still creating... [10s elapsed]
module.bucket.aws_s3_bucket.this: Creation complete after 11s [id=vertically-supposedly-morally-actual-escargot]
module.website.aws_s3_bucket.this: Creation complete after 13s [id=deadly-privately-pleasantly-uncommon-ox]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creating...
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/error.html]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Creation complete after 2s [id=/index.html]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket-arn = "arn:aws:s3:::vertically-supposedly-morally-actual-escargot"
bucket-name = "vertically-supposedly-morally-actual-escargot"
bucket-website-arn = "arn:aws:s3:::deadly-privately-pleasantly-uncommon-ox"
bucket-website-files = [
  "error.html",
  "index.html",
]
bucket-website-name = "deadly-privately-pleasantly-uncommon-ox"
bucket-website-url = "deadly-privately-pleasantly-uncommon-ox.s3-website-us-east-1.amazonaws.com"
pegando_file_path_apartir_da_raiz = [
  "deadly-privately-pleasantly-uncommon-ox/error.html",
  "deadly-privately-pleasantly-uncommon-ox/index.html",
]
teste_files_15_04_2022_da_raiz = {
  "error.html" = {
    "file" = "deadly-privately-pleasantly-uncommon-ox/error.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "a079b6818095cae21bf0d42a9369c0a6"
    "object_meta" = tomap(null) /* of string */
  }
  "index.html" = {
    "file" = "deadly-privately-pleasantly-uncommon-ox/index.html"
    "object_content_type" = "text/html; charset=utf-8"
    "object_etag" = "52d363c05c4a68ceaa5a3d934a89be97"
    "object_meta" = tomap(null) /* of string */
  }
}
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula21-Modules$ ^C

~~~~




- Efetuado o DESTROY:

~~~~bash

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - bucket-arn                        = "arn:aws:s3:::vertically-supposedly-morally-actual-escargot" -> null
  - bucket-name                       = "vertically-supposedly-morally-actual-escargot" -> null
  - bucket-website-arn                = "arn:aws:s3:::deadly-privately-pleasantly-uncommon-ox" -> null
  - bucket-website-files              = [
      - "error.html",
      - "index.html",
    ] -> null
  - bucket-website-name               = "deadly-privately-pleasantly-uncommon-ox" -> null
  - bucket-website-url                = "deadly-privately-pleasantly-uncommon-ox.s3-website-us-east-1.amazonaws.com" -> null
  - pegando_file_path_apartir_da_raiz = [
      - "deadly-privately-pleasantly-uncommon-ox/error.html",
      - "deadly-privately-pleasantly-uncommon-ox/index.html",
    ] -> null
  - teste_files_15_04_2022_da_raiz    = {
      - error.html = {
          - file                = "deadly-privately-pleasantly-uncommon-ox/error.html"
          - object_content_type = "text/html; charset=utf-8"
          - object_etag         = "a079b6818095cae21bf0d42a9369c0a6"
          - object_meta         = {}
        }
      - index.html = {
          - file                = "deadly-privately-pleasantly-uncommon-ox/index.html"
          - object_content_type = "text/html; charset=utf-8"
          - object_etag         = "52d363c05c4a68ceaa5a3d934a89be97"
          - object_meta         = {}
        }
    } -> null
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Destroying... [id=/index.html]
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Destroying... [id=/error.html]
module.bucket.aws_s3_bucket.this: Destroying... [id=vertically-supposedly-morally-actual-escargot]
module.website.module.objects["index.html"].aws_s3_bucket_object.this: Destruction complete after 0s
module.website.module.objects["error.html"].aws_s3_bucket_object.this: Destruction complete after 0s
module.website.aws_s3_bucket.this: Destroying... [id=deadly-privately-pleasantly-uncommon-ox]
module.bucket.aws_s3_bucket.this: Destruction complete after 0s
random_pet.this: Destroying... [id=vertically-supposedly-morally-actual-escargot]
random_pet.this: Destruction complete after 0s
module.website.aws_s3_bucket.this: Destruction complete after 1s
random_pet.website: Destroying... [id=deadly-privately-pleasantly-uncommon-ox]
random_pet.website: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.

~~~~
