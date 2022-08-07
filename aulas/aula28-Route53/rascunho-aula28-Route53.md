
# Aula 28 - Route 53

# resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git add .
git commit -m "Aula 28 - Route 53 - Site estático"
git push

# DIA 07/08/2022

Seguindo o diagrama, temos os seguintes recursos criados até o momento

1. Bucket de arquivos estáticos
2. Bucket de Redirect
3. Bucket de logs
4. CDN - Cloudfront


Estão faltando:

1. Parte de rotas
2. Aplicar certificado, para que ele seja HTTPS



# Route53

- Criando arquivo para o Route53
route53.tf

- Antes de seguir, criar a Hosted Zone no Route53.

- Acessando painel da Hostinger, onde tenho o dominio:
fernandomullerjr.site
<https://www.hostinger.com.br/cpanel-login>


- Criada a Hosted Zone, criou sozinho os registros:

fernandomullerjr.site	NS	Simple	-	
  ns-1945.awsdns-51.co.uk.
  ns-780.awsdns-33.net.
  ns-379.awsdns-47.com.
  ns-1339.awsdns-39.org.

fernandomullerjr.site	SOA	Simple	-	
  ns-1945.awsdns-51.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400



- No arquivo do Terraform route53.tf, vamos criar um data, que pega informação da nossa Hosted Zone:

~~~~h
data "aws_route53_zone" "this" {
  count = local.has_domain ? 1 : 0

  name = "${local.domain}."
}
~~~~

- Observação:
é necessário ter 1 ponto final ao final do nome da Hosted Zone, porque a AWS configura dessa maneira.



# #####################################################################################################################################################
# Explicando o count

- Para termos um código flexível, para quando a gente não tiver um domínio customizado, iremos um count.

count = local.has_domain ? 1 : 0

1. Verificar se tem um domínio.
2. Se tiver um domínio, vai criar o Hosted Zone.
3. Se não tiver um domínio, não vai criar

count = local.has_domain ? 1 : 0




# Criando os registros

- Só vai criar se a gente passar um domínio.
- Nosso nome, vai ser o nosso domínio.
- O tipo vai ser "A".
- O Zone ID vai ser passado via data. Como o data está buscando de uma lista, devido o fato de ter usado o count anteriormente, para acessar os valores dessa lista precisamos usar o index da lista, por exemplo:
[0]
- Como sabemos que só temos 1 elemento, o valor do index será [0] mesmo, como o primeiro item da lista.
- No campo sobre Alias, vamos apontar para o Cloudfront Distribution que criamos anteriormente.

~~~~h
resource "aws_route53_record" "website" {
  count = local.has_domain ? 1 : 0

  name    = local.domain
  type    = "A"
  zone_id = data.aws_route53_zone.this[0].zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
  }
}
~~~~



# resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git add .
git commit -m "Aula 28 - Route 53 - Site estático, adicionando route53.tf"
git push



- Criando um bloco de código para gerar o registro WWW.
- Vai seguir a mesma lógica que o registro website, só vai gerar se existir um domínio.
- Apenas o nome vai mudar um pouco, vai ter o www. na frente:
name    = "www.${local.domain}"
- Foi necessário usar a interpolação para passar o www. na frente do domínio.

~~~~h
resource "aws_route53_record" "www" {
  count = local.has_domain ? 1 : 0

  name    = "www.${local.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.this[0].zone_id

  alias {
    evaluate_target_health = false
    name                   = module.redirect.website_domain
    zone_id                = module.redirect.hosted_zone_id
  }
}
~~~~



- Ajustando a formatação.
- Validando o Terraform.
cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform
terraform fmt -recursive
terraform validate

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$ cd /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$ terraform fmt -recursive
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$
~~~~




- Efetuando o plan sem passar variável de domínio, ele indica que não existem alterações a serem feitas pelo Terraform:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$ terraform plan
Acquiring state lock. This may take a few moments...
random_pet.website: Refreshing state... [id=mainly-gladly-mistakenly-modern-crayfish]
aws_cloudfront_origin_access_identity.this: Refreshing state... [id=E1WAHT6F0TMQQA]
module.logs.aws_s3_bucket.this: Refreshing state... [id=mainly-gladly-mistakenly-modern-crayfish-logs]
module.website.aws_s3_bucket.this: Refreshing state... [id=mainly-gladly-mistakenly-modern-crayfish]
module.redirect.aws_s3_bucket.this: Refreshing state... [id=www.mainly-gladly-mistakenly-modern-crayfish]
aws_cloudfront_distribution.this: Refreshing state... [id=E18OGVTNZBEKXE]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"]: Refreshing state... [id=static/css/main.073c9b0a.css.map]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"]: Refreshing state... [id=static/css/main.073c9b0a.css]
module.website.module.objects.aws_s3_bucket_object.this["index.html"]: Refreshing state... [id=index.html]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"]: Refreshing state... [id=static/js/main.d58be654.js.LICENSE.txt]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"]: Refreshing state... [id=static/js/main.d58be654.js.map]
module.website.module.objects.aws_s3_bucket_object.this["robots.txt"]: Refreshing state... [id=robots.txt]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"]: Refreshing state... [id=static/js/main.d58be654.js]
module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"]: Refreshing state... [id=favicon.ico]
module.website.module.objects.aws_s3_bucket_object.this["logo192.png"]: Refreshing state... [id=logo192.png]
module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"]: Refreshing state... [id=asset-manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"]: Refreshing state... [id=static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js.map]
module.website.module.objects.aws_s3_bucket_object.this["logo512.png"]: Refreshing state... [id=logo512.png]
module.website.module.objects.aws_s3_bucket_object.this["manifest.json"]: Refreshing state... [id=manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_cloudfront_distribution.this has changed
  ~ resource "aws_cloudfront_distribution" "this" {
      + aliases                        = []
        id                             = "E18OGVTNZBEKXE"
        tags                           = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
[...]
Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may
include actions to undo or respond to these changes.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

No changes. Your infrastructure matches the configuration.
~~~~





- Efetuando o plan passando a variável com o domínio:
terraform plan -var="domain=fernandomullerjr.site"

1. Ele vai destruir os buckets que criamos via RandomPet.
2. Vai substituir pelo nosso domínio.

- Apresentou o erro:

~~~~bash
aws_cloudfront_distribution.this: Refreshing state... [id=E18OGVTNZBEKXE]
╷
│ Error: Reference to undeclared resource
│
│   on cloudfront.tf line 61, in resource "aws_cloudfront_distribution" "this":
│   61:       acm_certificate_arn = aws_acm_certificate.this[0].arn
│
│ A managed resource "aws_acm_certificate" "this" has not been declared in the root module.
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$
~~~~



- Comentei as configurações sobre ACM no arquivo do Cloudfront:
terraform-aws/aulas/aula28-Route53/terraform/cloudfront.tf



- Seguiu com erro

~~~~bash
module.redirect.aws_s3_bucket.this: Refreshing state... [id=www.mainly-gladly-mistakenly-modern-crayfish]
aws_cloudfront_distribution.this: Refreshing state... [id=E18OGVTNZBEKXE]
╷
│ Error: Insufficient viewer_certificate blocks
│
│   on cloudfront.tf line 5, in resource "aws_cloudfront_distribution" "this":
│    5: resource "aws_cloudfront_distribution" "this" {
│
│ At least 1 "viewer_certificate" blocks are required.
╵
~~~~




- Ao invés de comentar todo o bloco do "viewer_certificate", comentei somente a linha do ACM, daí o plan ficou ok:

~~~~h
  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [0] : []
    content {
#      acm_certificate_arn = aws_acm_certificate.this[0].arn
      ssl_support_method  = "sni-only"
    }
  }
~~~~


- Resultado do plan:

~~~~bash
Terraform will perform the following actions:

  # aws_cloudfront_distribution.this will be updated in-place
  ~ resource "aws_cloudfront_distribution" "this" {
      ~ aliases                        = [
          + "fernandomullerjr.site",
        ]
        id                             = "E18OGVTNZBEKXE"
        tags                           = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
        # (17 unchanged attributes hidden)

      ~ default_cache_behavior {
          ~ target_origin_id       = "mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> (known after apply)
            # (9 unchanged attributes hidden)

            # (1 unchanged block hidden)
        }

      ~ logging_config {
          ~ bucket          = "mainly-gladly-mistakenly-modern-crayfish-logs.s3.amazonaws.com" -> (known after apply)
            # (2 unchanged attributes hidden)
        }

      - origin {
          - domain_name = "mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> null
          - origin_id   = "mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> null

          - s3_origin_config {
              - origin_access_identity = "origin-access-identity/cloudfront/E1WAHT6F0TMQQA" -> null
            }
        }
      + origin {
          + domain_name = (known after apply)
          + origin_id   = (known after apply)

          + s3_origin_config {
              + origin_access_identity = "origin-access-identity/cloudfront/E1WAHT6F0TMQQA"
            }
        }


      ~ viewer_certificate {
          - cloudfront_default_certificate = true -> null
          + ssl_support_method             = "sni-only"
            # (1 unchanged attribute hidden)
        }
        # (1 unchanged block hidden)
    }

  # aws_cloudfront_origin_access_identity.this will be updated in-place
  ~ resource "aws_cloudfront_origin_access_identity" "this" {
      ~ comment                         = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site"
        id                              = "E1WAHT6F0TMQQA"
        # (5 unchanged attributes hidden)
    }

  # aws_route53_record.website[0] will be created
  + resource "aws_route53_record" "website" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z06652891LCL8TP3EH2UG"

      + alias {
          + evaluate_target_health = false
          + name                   = "dd8gecyr9fae5.cloudfront.net"
          + zone_id                = "Z2FDTNDATAQYW2"
        }
    }

  # aws_route53_record.www[0] will be created
  + resource "aws_route53_record" "www" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "www.fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z06652891LCL8TP3EH2UG"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

  # module.logs.aws_s3_bucket.this must be replaced
-/+ resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      ~ arn                         = "arn:aws:s3:::mainly-gladly-mistakenly-modern-crayfish-logs" -> (known after apply)
      ~ bucket                      = "mainly-gladly-mistakenly-modern-crayfish-logs" -> "fernandomullerjr.site-logs" # forces replacement
      ~ bucket_domain_name          = "mainly-gladly-mistakenly-modern-crayfish-logs.s3.amazonaws.com" -> (known after apply)
      ~ bucket_regional_domain_name = "mainly-gladly-mistakenly-modern-crayfish-logs.s3.amazonaws.com" -> (known after apply)
      ~ force_destroy               = true -> false
      ~ hosted_zone_id              = "Z3AQBSTGFYJSTF" -> (known after apply)
      ~ id                          = "mainly-gladly-mistakenly-modern-crayfish-logs" -> (known after apply)
      ~ region                      = "us-east-1" -> (known after apply)
      ~ request_payer               = "BucketOwner" -> (known after apply)
        tags                        = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
        # (1 unchanged attribute hidden)

      ~ versioning {
          ~ enabled    = false -> (known after apply)
          ~ mfa_delete = false -> (known after apply)
        }
    }

  # module.redirect.aws_s3_bucket.this must be replaced
-/+ resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      ~ arn                         = "arn:aws:s3:::www.mainly-gladly-mistakenly-modern-crayfish" -> (known after apply)
      ~ bucket                      = "www.mainly-gladly-mistakenly-modern-crayfish" -> "www.fernandomullerjr.site" # forces replacement
      ~ bucket_domain_name          = "www.mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> (known after apply)
      ~ bucket_regional_domain_name = "www.mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> (known after apply)
      ~ force_destroy               = true -> false
      ~ hosted_zone_id              = "Z3AQBSTGFYJSTF" -> (known after apply)
      ~ id                          = "www.mainly-gladly-mistakenly-modern-crayfish" -> (known after apply)
      ~ region                      = "us-east-1" -> (known after apply)
      ~ request_payer               = "BucketOwner" -> (known after apply)
        tags                        = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
      ~ website_domain              = "s3-website-us-east-1.amazonaws.com" -> (known after apply)
      ~ website_endpoint            = "www.mainly-gladly-mistakenly-modern-crayfish.s3-website-us-east-1.amazonaws.com" -> (known after apply)
        # (1 unchanged attribute hidden)

      ~ versioning {
          ~ enabled    = false -> (known after apply)
          ~ mfa_delete = false -> (known after apply)
        }

      ~ website {
          ~ redirect_all_requests_to = "mainly-gladly-mistakenly-modern-crayfish.s3-website-us-east-1.amazonaws.com" -> "fernandomullerjr.site"
        }
    }

  # module.website.aws_s3_bucket.this must be replaced
-/+ resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      ~ arn                         = "arn:aws:s3:::mainly-gladly-mistakenly-modern-crayfish" -> (known after apply)
      ~ bucket                      = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ bucket_domain_name          = "mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> (known after apply)
      ~ bucket_regional_domain_name = "mainly-gladly-mistakenly-modern-crayfish.s3.amazonaws.com" -> (known after apply)
      ~ force_destroy               = true -> false
      ~ hosted_zone_id              = "Z3AQBSTGFYJSTF" -> (known after apply)
      ~ id                          = "mainly-gladly-mistakenly-modern-crayfish" -> (known after apply)
      ~ policy                      = jsonencode(
          ~ {
              ~ Statement = [
                  ~ {
                      ~ Resource  = "arn:aws:s3:::mainly-gladly-mistakenly-modern-crayfish/*" -> "arn:aws:s3:::fernandomullerjr.site/*"
                        # (4 unchanged elements hidden)
                    },
                ]
                # (1 unchanged element hidden)
            }
        )
      ~ region                      = "us-east-1" -> (known after apply)
      ~ request_payer               = "BucketOwner" -> (known after apply)
        tags                        = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
      ~ website_domain              = "s3-website-us-east-1.amazonaws.com" -> (known after apply)
      ~ website_endpoint            = "mainly-gladly-mistakenly-modern-crayfish.s3-website-us-east-1.amazonaws.com" -> (known after apply)
        # (1 unchanged attribute hidden)

      - logging {
          - target_bucket = "mainly-gladly-mistakenly-modern-crayfish-logs" -> null
          - target_prefix = "access/" -> null
        }
      + logging {
          + target_bucket = (known after apply)
          + target_prefix = "access/"
        }


      ~ website {
            # (2 unchanged attributes hidden)
        }
        # (1 unchanged block hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "asset-manifest.json" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "FshtJX6C0WXfIPT.zgq2ZOUSoA7Vea08" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "favicon.ico" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "WovhiU1w0JD_JKXkd9A8M.O05XgVQ8d5" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["index.html"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "index.html" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "w9fEyucRwRA8xpzfXO7ftmuVLqJumvip" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo192.png"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "logo192.png" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "HYwswCnAKt2jd_fJucmzPtGpUD5sU0uS" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo512.png"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "logo512.png" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "Q4g1MQWnvkqWDatW_5yBPnEaUzYMDWBP" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["manifest.json"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "manifest.json" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "CyIWijFPSVQznOVfkLLr8X30PD6d6.Od" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["robots.txt"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "robots.txt" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "WIJ.KfFbhdyta8xlHQzDHiJYgsJuJxzn" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/css/main.073c9b0a.css" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "d1bjtdoWaDeEeMlkoCa3GwJtJtmsjbF_" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/css/main.073c9b0a.css.map" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "H_r3v0PYKxkKMFDWwUN6tUWwkdvizTWB" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/js/787.71e672d5.chunk.js" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "zDU7Qf9Bem2RQv8jR0o1eK5cvAf8lEMn" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/js/787.71e672d5.chunk.js.map" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "P0w4jrtn11l4rOXE2vyfQn_BYsiGYZC4" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/js/main.d58be654.js" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "1GN_nSfzGivUOk.6puc9x0qoVp3zHvqn" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/js/main.d58be654.js.LICENSE.txt" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "WvpZXmydi6eP4ruFp0Jk9lXJ6xQ2G7jP" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/js/main.d58be654.js.map" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "7fB1MnM4GrJ3uiK50LTCTFK4EO.s9Bwd" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"] must be replaced
-/+ resource "aws_s3_bucket_object" "this" {
      ~ bucket                 = "mainly-gladly-mistakenly-modern-crayfish" -> "fernandomullerjr.site" # forces replacement
      ~ id                     = "static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg" -> (known after apply)
      + kms_key_id             = (known after apply)
      - metadata               = {} -> null
      + server_side_encryption = (known after apply)
      ~ storage_class          = "STANDARD" -> (known after apply)
      - tags                   = {} -> null
      ~ version_id             = "lDEY_hPZZTJodgz.ydE0zGDHwPyimQwG" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

Plan: 20 to add, 2 to change, 18 to destroy.

Changes to Outputs:
  ~ website-url = "mainly-gladly-mistakenly-modern-crayfish.s3-website-us-east-1.amazonaws.com" -> "fernandomullerjr.site"

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$
~~~~





- Aplicando a configuração do Terraform
terraform apply -var="domain=fernandomullerjr.site" -auto-approve


- Ficou em looping no "modifying" do Cloudfront:

aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 46m52s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 47m2s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 47m12s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 47m22s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 47m32s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 47m42s elapsed]




- Adicionando o cloudfront_default_certificate = true no bloco do Cloudfront:

~~~~h
  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [0] : []
    content {
#      acm_certificate_arn = aws_acm_certificate.this[0].arn
      cloudfront_default_certificate = true
      ssl_support_method  = "sni-only"
    }
  }
~~~~


- Efetuando plan, planeja adicionar 1 recurso:

~~~~bash
  # aws_route53_record.website[0] will be created
  + resource "aws_route53_record" "website" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z06652891LCL8TP3EH2UG"

      + alias {
          + evaluate_target_health = false
          + name                   = "dd8gecyr9fae5.cloudfront.net"
          + zone_id                = "Z2FDTNDATAQYW2"
        }
    }

Plan: 1 to add, 1 to change, 0 to destroy.
~~~~




- Efetuando novo apply as 14:36:
terraform apply -var="domain=fernandomullerjr.site" -auto-approve




aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 20s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 30s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 40s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 50s elapsed]
aws_cloudfront_distribution.this: Still modifying... [id=E18OGVTNZBEKXE, 1m0s elapsed]
╷
│ Error: error updating CloudFront Distribution (E18OGVTNZBEKXE): InvalidViewerCertificate: To add an alternate domain name (CNAME) to a CloudFront distribution, you must attach a trusted certificate that validates your authorization to use the domain name. For more details, see: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html#alternate-domain-names-requirements
│       status code: 400, request id: a569d62d-c923-4cc9-8118-660b90ce373c
│
│   with aws_cloudfront_distribution.this,
│   on cloudfront.tf line 5, in resource "aws_cloudfront_distribution" "this":
│    5: resource "aws_cloudfront_distribution" "this" {
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$



- Seguiu com erro.
- Observação:
No video do Cleber, o Cloudfront até conseguiu ser aplicado, mas não vinha com CNAME, porque o domínio não conseguia ser registrado.
No meu caso o Cloudfront não consegue terminar o apply devido a falta do certificado.


- No S3 os buckets com o domínio foram criados corretamente:

Buckets(4)
Buckets are containers for data stored in S3. Learn more

	Name
AWS Region
	Access
	Creation date
	fernandomullerjr.site	US East (N. Virginia) us-east-1	
Public
	August 7, 2022, 13:42:48 (UTC-03:00)
	fernandomullerjr.site-logs	US East (N. Virginia) us-east-1	Objects can be public
	August 7, 2022, 13:42:37 (UTC-03:00)
	tfstate-261106957109	US East (N. Virginia) us-east-1	Objects can be public
	July 27, 2022, 21:18:17 (UTC-03:00)
	www.fernandomullerjr.site	US East (N. Virginia) us-east-1	
Public
	August 7, 2022, 13:43:05 (UTC-03:00)



- Efetuando o destroy as 14:43h:



Plan: 0 to add, 0 to change, 5 to destroy.

Changes to Outputs:
  - cdn-url         = "dd8gecyr9fae5.cloudfront.net" -> null
  - distribution-id = "E18OGVTNZBEKXE" -> null
aws_cloudfront_distribution.this: Destroying... [id=E18OGVTNZBEKXE]
╷
│ Error: error disabling CloudFront Distribution (E18OGVTNZBEKXE): InvalidArgument: The S3 bucket that you specified for CloudFront logs doesn't exist: mainly-gladly-mistakenly-modern-crayfish-logs.s3.amazonaws.com
│       status code: 400, request id: 7f10aa79-8206-48b6-a385-2adf0070d0d0
│
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$



- Erro ao tentar deletar a origin via console na AWS:
Failed to delete origin: 1 validation error detected: Value '[]' at 'distributionConfig.origins.items' failed to satisfy constraint: Member must have length greater than or equal to 1


- Criado bucket vazio chamado mainly-gladly-mistakenly-modern-crayfish
mainly-gladly-mistakenly-modern-crayfish

- Tentando novo destroy.

- Agora foi:

~~~~bash

    }

  # module.logs.aws_s3_bucket.this will be destroyed
  - resource "aws_s3_bucket" "this" {
      - acl                         = "log-delivery-write" -> null
      - arn                         = "arn:aws:s3:::fernandomullerjr.site-logs" -> null
      - bucket                      = "fernandomullerjr.site-logs" -> null
      - bucket_domain_name          = "fernandomullerjr.site-logs.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "fernandomullerjr.site-logs.s3.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3AQBSTGFYJSTF" -> null
      - id                          = "fernandomullerjr.site-logs" -> null
      - region                      = "us-east-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "CreatedAt" = "2022-07-23"
          - "Module"    = "3"
          - "Project"   = "Curso AWS com Terraform"
          - "Service"   = "Static Website"
        } -> null

      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }
    }

  # module.website.aws_s3_bucket.this will be destroyed
  - resource "aws_s3_bucket" "this" {
      - acl                         = "public-read" -> null
      - arn                         = "arn:aws:s3:::fernandomullerjr.site" -> null
      - bucket                      = "fernandomullerjr.site" -> null
      - bucket_domain_name          = "fernandomullerjr.site.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "fernandomullerjr.site.s3.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3AQBSTGFYJSTF" -> null
      - id                          = "fernandomullerjr.site" -> null
      - policy                      = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "s3:GetObject"
                      - Effect    = "Allow"
                      - Principal = {
                          - AWS = "*"
                        }
                      - Resource  = "arn:aws:s3:::fernandomullerjr.site/*"
                      - Sid       = "PublicReadForGetBucketObjects"
                    },
                ]
              - Version   = "2008-10-17"
            }
        ) -> null
      - region                      = "us-east-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "CreatedAt" = "2022-07-23"
          - "Module"    = "3"
          - "Project"   = "Curso AWS com Terraform"
          - "Service"   = "Static Website"
        } -> null
      - website_domain              = "s3-website-us-east-1.amazonaws.com" -> null
      - website_endpoint            = "fernandomullerjr.site.s3-website-us-east-1.amazonaws.com" -> null

      - logging {
          - target_bucket = "fernandomullerjr.site-logs" -> null
          - target_prefix = "access/" -> null
        }

      - versioning {
          - enabled    = true -> null
          - mfa_delete = false -> null
        }

      - website {
          - error_document = "index.html" -> null
          - index_document = "index.html" -> null
        }
    }

Plan: 0 to add, 0 to change, 5 to destroy.

Changes to Outputs:
  - cdn-url         = "dd8gecyr9fae5.cloudfront.net" -> null
  - distribution-id = "E18OGVTNZBEKXE" -> null
aws_cloudfront_distribution.this: Destroying... [id=E18OGVTNZBEKXE]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 10s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 20s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 30s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 40s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 50s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m0s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m10s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m20s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m30s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m40s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 1m50s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m0s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m10s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m20s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m30s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m40s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 2m50s elapsed]
aws_cloudfront_distribution.this: Still destroying... [id=E18OGVTNZBEKXE, 3m0s elapsed]
aws_cloudfront_distribution.this: Destruction complete after 3m9s
aws_cloudfront_origin_access_identity.this: Destroying... [id=E1WAHT6F0TMQQA]
module.website.aws_s3_bucket.this: Destroying... [id=fernandomullerjr.site]
module.website.aws_s3_bucket.this: Destruction complete after 0s
module.logs.aws_s3_bucket.this: Destroying... [id=fernandomullerjr.site-logs]
aws_cloudfront_origin_access_identity.this: Destruction complete after 0s
╷
│ Error: error deleting S3 Bucket (fernandomullerjr.site-logs): BucketNotEmpty: The bucket you tried to delete is not empty
│       status code: 409, request id: JRRHH5YSM9X4MZW4, host id: ISEmZwMl52xkLAi8i+MViEwi+pskJEBxW55GcaG6VdfaRt96J9K8Hpqe2/9FCAq7e3G6kX44YNs=
│
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$ terraform destroy -auto-approve
Acquiring state lock. This may take a few moments...
random_pet.website: Refreshing state... [id=mainly-gladly-mistakenly-modern-crayfish]
module.logs.aws_s3_bucket.this: Refreshing state... [id=fernandomullerjr.site-logs]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # random_pet.website will be destroyed
  - resource "random_pet" "website" {
      - id        = "mainly-gladly-mistakenly-modern-crayfish" -> null
      - length    = 5 -> null
      - separator = "-" -> null
    }

  # module.logs.aws_s3_bucket.this will be destroyed
  - resource "aws_s3_bucket" "this" {
      - acl                         = "log-delivery-write" -> null
      - arn                         = "arn:aws:s3:::fernandomullerjr.site-logs" -> null
      - bucket                      = "fernandomullerjr.site-logs" -> null
      - bucket_domain_name          = "fernandomullerjr.site-logs.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "fernandomullerjr.site-logs.s3.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3AQBSTGFYJSTF" -> null
      - id                          = "fernandomullerjr.site-logs" -> null
      - region                      = "us-east-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "CreatedAt" = "2022-07-23"
          - "Module"    = "3"
          - "Project"   = "Curso AWS com Terraform"
          - "Service"   = "Static Website"
        } -> null

      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
module.logs.aws_s3_bucket.this: Destroying... [id=fernandomullerjr.site-logs]
module.logs.aws_s3_bucket.this: Destruction complete after 1s
random_pet.website: Destroying... [id=mainly-gladly-mistakenly-modern-crayfish]
random_pet.website: Destruction complete after 0s
Releasing state lock. This may take a few moments...

Destroy complete! Resources: 2 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula28-Route53/terraform$

~~~~


# PENDENTE
- Destroy da infra antiga.
- Acompanhar billing e Hosted Zone.
- Seguir para aula 30 e criar o certificado, para poder criar toda a infra.
- Usar o meu dominio da Hostinger.


