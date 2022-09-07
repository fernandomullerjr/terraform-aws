
# Aula 29 - Certificado SSL - ACM.



# ########################################################################################################################################################
# ########################################################################################################################################################
#  resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 29 - Certificado SSL - ACM. pt1"
git push
git status




# ########################################################################################################################################################
# ########################################################################################################################################################
# IMPORTANTE

- Neste projeto usando S3, Cloudfront, etc, é necessário iniciar o backend no S3, senão não é possível fazer init, plan, etc!!!!!!!!!!
- Neste projeto usando S3, Cloudfront, etc, é necessário iniciar o backend no S3, senão não é possível fazer init, plan, etc!!!!!!!!!!
- Neste projeto usando S3, Cloudfront, etc, é necessário iniciar o backend no S3, senão não é possível fazer init, plan, etc!!!!!!!!!!

- Foi necessário usar o comando abaixo, informando o caminho do arquivo hcl com as configurações do Backend:
terraform init -backend-config=backend.hcl

- Efetuando o plan passando a variável com o domínio:
terraform plan -var="domain=fernandomullerjr.site"


# ########################################################################################################################################################
# ########################################################################################################################################################
# DIA 04/09/2022

- Seguindo o diagrama atual, está faltando o certificado para a nossa estrutura, para certificar que o domínio pertence a nós mesmos. Também é necessário o certificado para que o nosso site utilize HTTPS.

- Usar o serviço ACM e requisitar um certificado.

- Devido a região do certificado e recursos, é necessário criar um alias para a região da Virginia us-east-1 no main.tf
- O ACM precisa que que o certificado esteja na Virginia(avaliar melhor sobre isto depois).



- Adicionando ao main.tf:

~~~~h
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  alias   = "us-east-1"
}
~~~~




- Criando arquivo acm.tf
<https://github.com/chgasparoto/curso-aws-com-terraform/blob/master/03-site-estatico/terraform/acm.tf>

~~~~h
resource "aws_acm_certificate" "this" {
  count = local.has_domain ? 1 : 0

  provider = aws.us-east-1

  domain_name               = local.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${local.domain}"]
}

resource "aws_acm_certificate_validation" "this" {
  count = local.has_domain ? 1 : 0

  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
~~~~

1 - Só vai criar o certificado se o domínio estiver setado. Usando esta condição:
    count = local.has_domain ? 1 : 0


2 - Devido o Count na criação do certificado, ele forma uma lista, para acessar a lista precisamos passar o número do indice, quando vamos chamar o certificado em outro recurso, por exemplo, no bloco de validação do certificado, usamos o valor 0 para acessar o certificado:
    certificate_arn         = aws_acm_certificate.this[0].arn







- Documentação do Terraform sobre ACM, explicando a validação via DNS e trazendo exemplo:
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate#referencing-domain_validation_options-with-for_each-based-resources>

Referencing domain_validation_options With for_each Based Resources
See the aws_acm_certificate_validation resource for a full example of performing DNS validation.

~~~~h
resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}
~~~~



- Teremos 2 certificados
fernandomullerjr.site
*.fernandomullerjr.site


- A partir do exemplo fornecido pela documentação da Terraform, precisamos editar o nome do recurso, colocando "this" e acessando o valor 0 do index.
this[0]


ROUTE53 - editado

~~~~h
resource "aws_route53_record" "cert_validation" {
  provider = aws.us-east-1

  for_each = local.has_domain ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[0].zone_id
}
~~~~




- Além do que fizemos sobre o Route53, é importante garantir que o acm.tf tenha o "for"
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation#dns-validation-with-route-53>
    validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

~~~~h
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"
  aliases             = local.has_domain ? [local.domain] : []
~~~~

- No Cloudfront é necessário informar o alias do meu domínio para ele.
    aliases             = local.has_domain ? [local.domain] : []





- Em relação ao certificado, para podermos usar 1 domínio personalizado ou 1 domínio fornecido pelo Cloudfront, precisamos usar Dynamic.

1 - Conferir se tem 1 domínio, se tiver 1 domínio, vai receber uma lista vazia, não vai executar o que existe no "content".
Caso não tenha 1 domínio, vai executar o que existe no "content" e usar um certificado fornecido pelo Cloudfront mesmo:

~~~~h
  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [] : [0]
    content {
      cloudfront_default_certificate = true
    }
  }
~~~~

2 - Caso contrário, se tivermos 1 domínio personalizado, iremos usar um segundo Dynamic, que irá executar o content, já que temos o domínio personalizado:
comentando o "cloudfront_default_certificate = true" que tinha sido usado antes de ter um dominio personalizado

~~~~h
  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [0] : []
    content {
      acm_certificate_arn = aws_acm_certificate.this[0].arn
#      cloudfront_default_certificate = true
      ssl_support_method  = "sni-only"
    }
  }
~~~~



- Deletando a hosted zone atual no braço via console, para ver se o Terraform vai criar tudo.


- Foi necessário usar o comando abaixo, informando o caminho do arquivo hcl com as configurações do Backend:
terraform init -backend-config=backend.hcl

- Efetuando o plan passando a variável com o domínio:
terraform plan -var="domain=fernandomullerjr.site"



- ERRO

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$ terraform plan
Acquiring state lock. This may take a few moments...
╷
│ Error: no matching Route53Zone found
│
│   with data.aws_route53_zone.this[0],
│   on route53.tf line 1, in data "aws_route53_zone" "this":
│    1: data "aws_route53_zone" "this" {
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$






Had the same error "Error: no matching Route53Zone found" when using aws provider alias, our cause was the incorrect aws access id/key and once sorted worked fine, we didn't need the . for the record :)
Share
Edit
Follow
answered Jul 8 at 22:31
user avatar
Matt Duguid
111 bronze badge
Add a comment
-1

This does not seem to work when it is placed inside a module. Simply move it to the manifest where the module is called at the root level.



# push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 29 - Certificado SSL - ACM. pt2. TSHOOT, erro no Route53"
git push
git status



# PENDENTE
- TSHOOT, erros durante plan e apply, devido a Zone do Route53.
- AVALIAR. - O ACM precisa que que o certificado esteja na Virginia(avaliar melhor sobre isto depois)



# Dia 07/09/2022

- Segue com erro no terraform plan:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$ terraform plan
Acquiring state lock. This may take a few moments...
╷
│ Error: no matching Route53Zone found
│
│   with data.aws_route53_zone.this[0],
│   on route53.tf line 1, in data "aws_route53_zone" "this":
│    1: data "aws_route53_zone" "this" {
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$
~~~~


- Criei a Hosted Zone manualmente via console
terraform plan


- Agora o plan funcionou!

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$ terraform plan
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_acm_certificate.this[0] will be created
  + resource "aws_acm_certificate" "this" {
      + arn                       = (known after apply)
      + domain_name               = "fernandomullerjr.site"
      + domain_validation_options = [
          + {
              + domain_name           = "*.fernandomullerjr.site"
              + resource_record_name  = (known after apply)
              + resource_record_type  = (known after apply)
              + resource_record_value = (known after apply)
            },
          + {
              + domain_name           = "fernandomullerjr.site"
              + resource_record_name  = (known after apply)
              + resource_record_type  = (known after apply)
              + resource_record_value = (known after apply)
            },
        ]
      + id                        = (known after apply)
      + status                    = (known after apply)
      + subject_alternative_names = [
          + "*.fernandomullerjr.site",
        ]
      + validation_emails         = (known after apply)
      + validation_method         = "DNS"
    }

  # aws_acm_certificate_validation.this[0] will be created
  + resource "aws_acm_certificate_validation" "this" {
      + certificate_arn         = (known after apply)
      + id                      = (known after apply)
      + validation_record_fqdns = (known after apply)
    }

  # aws_cloudfront_distribution.this will be created
  + resource "aws_cloudfront_distribution" "this" {
      + aliases                        = [
          + "fernandomullerjr.site",
        ]
      + arn                            = (known after apply)
      + caller_reference               = (known after apply)
      + comment                        = "Managed by Terraform"
      + default_root_object            = "index.html"
      + domain_name                    = (known after apply)
      + enabled                        = true
      + etag                           = (known after apply)
      + hosted_zone_id                 = (known after apply)
      + http_version                   = "http2"
      + id                             = (known after apply)
      + in_progress_validation_batches = (known after apply)
      + is_ipv6_enabled                = true
      + last_modified_time             = (known after apply)
      + price_class                    = "PriceClass_All"
      + retain_on_delete               = false
      + status                         = (known after apply)
      + tags                           = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
      + trusted_signers                = (known after apply)
      + wait_for_deployment            = true

      + default_cache_behavior {
          + allowed_methods        = [
              + "GET",
              + "HEAD",
              + "OPTIONS",
            ]
          + cached_methods         = [
              + "GET",
              + "HEAD",
            ]
          + compress               = false
          + default_ttl            = 3600
          + max_ttl                = 86400
          + min_ttl                = 0
          + target_origin_id       = (known after apply)
          + trusted_signers        = (known after apply)
          + viewer_protocol_policy = "redirect-to-https"

          + forwarded_values {
              + headers                 = [
                  + "Origin",
                ]
              + query_string            = false
              + query_string_cache_keys = (known after apply)

              + cookies {
                  + forward           = "none"
                  + whitelisted_names = (known after apply)
                }
            }
        }

      + logging_config {
          + bucket          = (known after apply)
          + include_cookies = true
          + prefix          = "cnd/"
        }

      + origin {
          + domain_name = (known after apply)
          + origin_id   = (known after apply)

          + s3_origin_config {
              + origin_access_identity = (known after apply)
            }
        }

      + restrictions {
          + geo_restriction {
              + locations        = (known after apply)
              + restriction_type = "none"
            }
        }

      + viewer_certificate {
          + acm_certificate_arn      = (known after apply)
          + minimum_protocol_version = "TLSv1"
          + ssl_support_method       = "sni-only"
        }
    }

  # aws_cloudfront_origin_access_identity.this will be created
  + resource "aws_cloudfront_origin_access_identity" "this" {
      + caller_reference                = (known after apply)
      + cloudfront_access_identity_path = (known after apply)
      + comment                         = "fernandomullerjr.site"
      + etag                            = (known after apply)
      + iam_arn                         = (known after apply)
      + id                              = (known after apply)
      + s3_canonical_user_id            = (known after apply)
    }

  # aws_route53_record.cert_validation["*.fernandomullerjr.site"] will be created
  + resource "aws_route53_record" "cert_validation" {
      + allow_overwrite = true
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = (known after apply)
      + records         = (known after apply)
      + ttl             = 60
      + type            = (known after apply)
      + zone_id         = "Z0647982JAWRY25D845S"
    }

  # aws_route53_record.cert_validation["fernandomullerjr.site"] will be created
  + resource "aws_route53_record" "cert_validation" {
      + allow_overwrite = true
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = (known after apply)
      + records         = (known after apply)
      + ttl             = 60
      + type            = (known after apply)
      + zone_id         = "Z0647982JAWRY25D845S"
    }

  # aws_route53_record.website[0] will be created
  + resource "aws_route53_record" "website" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z0647982JAWRY25D845S"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

  # aws_route53_record.www[0] will be created
  + resource "aws_route53_record" "www" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "www.fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z0647982JAWRY25D845S"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

  # random_pet.website will be created
  + resource "random_pet" "website" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

  # module.logs.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "log-delivery-write"
      + arn                         = (known after apply)
      + bucket                      = "fernandomullerjr.site-logs"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # module.redirect.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = "www.fernandomullerjr.site"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + redirect_all_requests_to = "fernandomullerjr.site"
        }
    }

  # module.website.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = "fernandomullerjr.site"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:GetObject"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "arn:aws:s3:::fernandomullerjr.site/*"
                      + Sid       = "PublicReadForGetBucketObjects"
                    },
                ]
              + Version   = "2008-10-17"
            }
        )
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + logging {
          + target_bucket = (known after apply)
          + target_prefix = "access/"
        }

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }

      + website {
          + error_document = "index.html"
          + index_document = "index.html"
        }
    }

  # module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/json"
      + etag                   = "2b99189cbc4ddac9cf486ecf59af88a2"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "asset-manifest.json"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/asset-manifest.json"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "image/vnd.microsoft.icon"
      + etag                   = "c92b85a5b907c70211f4ec25e29a8c4a"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "favicon.ico"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/favicon.ico"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["index.html"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "text/html; charset=utf-8"
      + etag                   = "388ccaafb727af791d148ac46cd3d3f2"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo192.png"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "image/png"
      + etag                   = "33dbdd0177549353eeeb785d02c294af"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "logo192.png"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/logo192.png"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["logo512.png"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "image/png"
      + etag                   = "917515db74ea8d1aee6a246cfbcc0b45"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "logo512.png"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/logo512.png"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["manifest.json"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/json"
      + etag                   = "d9d975cebe2ec20b6c652e1e4c12ccf0"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "manifest.json"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/manifest.json"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["robots.txt"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "text/plain; charset=utf-8"
      + etag                   = "fa1ded1ed7c11438a9b0385b1e112850"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "robots.txt"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/robots.txt"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "text/css; charset=utf-8"
      + etag                   = "89d76f95e100fc61f7271096ce86e7fc"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/css/main.073c9b0a.css"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/css/main.073c9b0a.css"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/octet-stream"
      + etag                   = "4284557f70f03d562b659f38b01eaa66"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/css/main.073c9b0a.css.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/css/main.073c9b0a.css.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/javascript"
      + etag                   = "d95602c8a8bdb73b00fa5ed23e902214"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/787.71e672d5.chunk.js"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/787.71e672d5.chunk.js"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/octet-stream"
      + etag                   = "048016cad13a1f842866ac9155dd2634"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/787.71e672d5.chunk.js.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/787.71e672d5.chunk.js.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/javascript"
      + etag                   = "5a6237f2967ef1def14f8451aa8e3182"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "text/plain; charset=utf-8"
      + etag                   = "b114cc85da504a772f040e3f40f8e46a"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js.LICENSE.txt"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js.LICENSE.txt"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "application/octet-stream"
      + etag                   = "fd1ad26d4746a2fbfed2145835fb7ddf"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/js/main.d58be654.js.map"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/js/main.d58be654.js.map"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"] will be created
  + resource "aws_s3_bucket_object" "this" {
      + acl                    = "private"
      + bucket                 = "fernandomullerjr.site"
      + content_type           = "image/svg+xml"
      + etag                   = "06e733283fa43d1dd57738cfc409adbd"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./../website/build/static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 27 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cdn-url         = (known after apply)
  + distribution-id = (known after apply)
  + website-url     = "fernandomullerjr.site"

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$
~~~~



12:27h - apply



12:38h - ainda fazendo criação do validation
aws_acm_certificate_validation.this[0]: Still creating... [10m16s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [10m26s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [10m36s elapsed]

- Verifiquei que os registros NS do Hosted Zone são diferentes do que estão na Hostinger.
- Atualizando a Hostinger


- Segue criando validation
- Certificado com status "Pending validation" ainda.


- Verificando documentação do Terraform, pode ser adicionado tempo de timeout maior, pois as vezes o ACM pode levar um tempo maior que o usual para a validação do certificado:
<https://github.com/hashicorp/terraform-provider-aws/issues/9338>
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation>
<https://www.terraform.io/language/resources/syntax#operation-timeouts>




- Devido os ajustes na Hostinger, sobre os NS da AWS Route53, foi parado o apply e sendo feito novo apply, para ver se resolve:

~~~~bash
aws_route53_record.cert_validation["fernandomullerjr.site"]: Destroying... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Destroying... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Destruction complete after 3s
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still destroying... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e...949d20c4e.fernandomullerjr.site._CNAME, 10s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still destroying... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e...949d20c4e.fernandomullerjr.site._CNAME, 20s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still destroying... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e...949d20c4e.fernandomullerjr.site._CNAME, 30s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Destruction complete after 34s
aws_acm_certificate.this[0]: Creating...
aws_acm_certificate.this[0]: Creation complete after 8s [id=arn:aws:acm:us-east-1:261106957109:certificate/2a21728f-2c3f-4b74-856c-8df96941b411]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Creating...
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Creating...
aws_cloudfront_distribution.this: Creating...
aws_route53_record.cert_validation["fernandomullerjr.site"]: Still creating... [10s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still creating... [10s elapsed]
aws_cloudfront_distribution.this: Still creating... [10s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still creating... [20s elapsed]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Still creating... [20s elapsed]
aws_cloudfront_distribution.this: Still creating... [20s elapsed]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Still creating... [30s elapsed]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Still creating... [30s elapsed]
aws_cloudfront_distribution.this: Still creating... [30s elapsed]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Creation complete after 34s [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Creation complete after 35s [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_acm_certificate_validation.this[0]: Creating...
aws_cloudfront_distribution.this: Still creating... [40s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [10s elapsed]
aws_cloudfront_distribution.this: Still creating... [50s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [20s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [30s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [40s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [50s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [1m0s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [1m10s elapsed]
~~~~



- Funcionou, mas deu um novo erro:

~~~~bash
aws_acm_certificate_validation.this[0]: Still creating... [8m10s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [8m20s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [8m30s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [8m40s elapsed]
aws_acm_certificate_validation.this[0]: Still creating... [8m50s elapsed]
aws_acm_certificate_validation.this[0]: Creation complete after 8m52s [id=2022-09-07 16:04:17.664 +0000 UTC]
╷
│ Error: error creating CloudFront Distribution: InvalidViewerCertificate: The specified SSL certificate doesn't exist, isn't in us-east-1 region, isn't valid, or doesn't include a valid certificate chain.
│       status code: 400, request id: 2071397c-31bc-4afb-aab8-d5ee445bed4f
│
│   with aws_cloudfront_distribution.this,
│   on cloudfront.tf line 5, in resource "aws_cloudfront_distribution" "this":
│    5: resource "aws_cloudfront_distribution" "this" {
│
╵
Releasing state lock. This may take a few moments...
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$
~~~~



- Adicionando o provider no manifesto do Cloudfront:
provider = aws.us-east-1
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform/cloudfront.tf


# push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 29 - Certificado SSL - ACM. pt2. TSHOOT, erros no certificado ACM. Erros no Cloudfront."
git push
git status


- Efetuando novo apply.

~~~~bash

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$ terraform validate
Success! The configuration is valid.

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$ terraform apply -auto-approve
Acquiring state lock. This may take a few moments...
random_pet.website: Refreshing state... [id=frankly-internally-horribly-welcome-killdeer]
aws_cloudfront_origin_access_identity.this: Refreshing state... [id=E3IAQISOYSYNGY]
module.logs.aws_s3_bucket.this: Refreshing state... [id=fernandomullerjr.site-logs]
aws_acm_certificate.this[0]: Refreshing state... [id=arn:aws:acm:us-east-1:261106957109:certificate/2a21728f-2c3f-4b74-856c-8df96941b411]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Refreshing state... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Refreshing state... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_acm_certificate_validation.this[0]: Refreshing state... [id=2022-09-07 16:04:17.664 +0000 UTC]
module.website.aws_s3_bucket.this: Refreshing state... [id=fernandomullerjr.site]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"]: Refreshing state... [id=static/js/main.d58be654.js.map]
module.website.module.objects.aws_s3_bucket_object.this["logo512.png"]: Refreshing state... [id=logo512.png]
module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"]: Refreshing state... [id=favicon.ico]
module.redirect.aws_s3_bucket.this: Refreshing state... [id=www.fernandomullerjr.site]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"]: Refreshing state... [id=static/css/main.073c9b0a.css]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js]
module.website.module.objects.aws_s3_bucket_object.this["robots.txt"]: Refreshing state... [id=robots.txt]
module.website.module.objects.aws_s3_bucket_object.this["index.html"]: Refreshing state... [id=index.html]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"]: Refreshing state... [id=static/js/main.d58be654.js]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"]: Refreshing state... [id=static/js/main.d58be654.js.LICENSE.txt]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"]: Refreshing state... [id=static/css/main.073c9b0a.css.map]
module.website.module.objects.aws_s3_bucket_object.this["logo192.png"]: Refreshing state... [id=logo192.png]
module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"]: Refreshing state... [id=static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg]
module.website.module.objects.aws_s3_bucket_object.this["manifest.json"]: Refreshing state... [id=manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"]: Refreshing state... [id=asset-manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js.map]
aws_route53_record.www[0]: Refreshing state... [id=Z0647982JAWRY25D845S_www.fernandomullerjr.site_A]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_acm_certificate.this[0] has changed
  ~ resource "aws_acm_certificate" "this" {
        id                        = "arn:aws:acm:us-east-1:261106957109:certificate/2a21728f-2c3f-4b74-856c-8df96941b411"
      ~ status                    = "PENDING_VALIDATION" -> "ISSUED"
      + tags                      = {}
        # (6 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

  # aws_route53_record.cert_validation["*.fernandomullerjr.site"] has changed
  ~ resource "aws_route53_record" "cert_validation" {
        id              = "Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME"
        name            = "_c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site"
        # (6 unchanged attributes hidden)
    }

  # aws_route53_record.cert_validation["fernandomullerjr.site"] has changed
  ~ resource "aws_route53_record" "cert_validation" {
        id              = "Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME"
        name            = "_c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site"
        # (6 unchanged attributes hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to
these changes.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudfront_distribution.this will be created
  + resource "aws_cloudfront_distribution" "this" {
      + aliases                        = [
          + "fernandomullerjr.site",
        ]
      + arn                            = (known after apply)
      + caller_reference               = (known after apply)
      + comment                        = "Managed by Terraform"
      + default_root_object            = "index.html"
      + domain_name                    = (known after apply)
      + enabled                        = true
      + etag                           = (known after apply)
      + hosted_zone_id                 = (known after apply)
      + http_version                   = "http2"
      + id                             = (known after apply)
      + in_progress_validation_batches = (known after apply)
      + is_ipv6_enabled                = true
      + last_modified_time             = (known after apply)
      + price_class                    = "PriceClass_All"
      + retain_on_delete               = false
      + status                         = (known after apply)
      + tags                           = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
      + trusted_signers                = (known after apply)
      + wait_for_deployment            = true

      + default_cache_behavior {
          + allowed_methods        = [
              + "GET",
              + "HEAD",
              + "OPTIONS",
            ]
          + cached_methods         = [
              + "GET",
              + "HEAD",
            ]
          + compress               = false
          + default_ttl            = 3600
          + max_ttl                = 86400
          + min_ttl                = 0
          + target_origin_id       = "fernandomullerjr.site.s3.amazonaws.com"
          + trusted_signers        = (known after apply)
          + viewer_protocol_policy = "redirect-to-https"

          + forwarded_values {
              + headers                 = [
                  + "Origin",
                ]
              + query_string            = false
              + query_string_cache_keys = (known after apply)

              + cookies {
                  + forward           = "none"
                  + whitelisted_names = (known after apply)
                }
            }
        }

      + logging_config {
          + bucket          = "fernandomullerjr.site-logs.s3.amazonaws.com"
          + include_cookies = true
          + prefix          = "cnd/"
        }

      + origin {
          + domain_name = "fernandomullerjr.site.s3.amazonaws.com"
          + origin_id   = "fernandomullerjr.site.s3.amazonaws.com"

          + s3_origin_config {
              + origin_access_identity = "origin-access-identity/cloudfront/E3IAQISOYSYNGY"
            }
        }

      + restrictions {
          + geo_restriction {
              + locations        = (known after apply)
              + restriction_type = "none"
            }
        }

      + viewer_certificate {
          + acm_certificate_arn      = "arn:aws:acm:us-east-1:261106957109:certificate/2a21728f-2c3f-4b74-856c-8df96941b411"
          + minimum_protocol_version = "TLSv1"
          + ssl_support_method       = "sni-only"
        }
    }

  # aws_route53_record.website[0] will be created
  + resource "aws_route53_record" "website" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "fernandomullerjr.site"
      + type            = "A"
      + zone_id         = "Z0647982JAWRY25D845S"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cdn-url         = (known after apply)
  + distribution-id = (known after apply)
aws_cloudfront_distribution.this: Creating...
aws_cloudfront_distribution.this: Still creating... [10s elapsed]
aws_cloudfront_distribution.this: Still creating... [20s elapsed]
aws_cloudfront_distribution.this: Still creating... [30s elapsed]
aws_cloudfront_distribution.this: Still creating... [40s elapsed]
aws_cloudfront_distribution.this: Still creating... [50s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m0s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m10s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m20s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m30s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m40s elapsed]
aws_cloudfront_distribution.this: Still creating... [1m50s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m0s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m10s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m20s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m30s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m40s elapsed]
aws_cloudfront_distribution.this: Still creating... [2m50s elapsed]
aws_cloudfront_distribution.this: Still creating... [3m0s elapsed]
aws_cloudfront_distribution.this: Creation complete after 3m7s [id=E3DUT01E7FPKW]
aws_route53_record.website[0]: Creating...
aws_route53_record.website[0]: Still creating... [10s elapsed]
aws_route53_record.website[0]: Still creating... [20s elapsed]
aws_route53_record.website[0]: Still creating... [30s elapsed]
aws_route53_record.website[0]: Creation complete after 39s [id=Z0647982JAWRY25D845S_fernandomullerjr.site_A]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

cdn-url = "d1oftwh0mbt813.cloudfront.net"
distribution-id = "E3DUT01E7FPKW"
website-url = "fernandomullerjr.site"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform$
~~~~




# ########################################################################################################################################################
# ########################################################################################################################################################
# SOLUÇÃO:
- Adicionando o provider no manifesto do Cloudfront:
provider = aws.us-east-1
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula29-Certificado-SSL---ACM/terraform/cloudfront.tf



- Site acessível via Cloudfront:
cdn-url = "d1oftwh0mbt813.cloudfront.net"

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber$ curl d1oftwh0mbt813.cloudfront.net
<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>CloudFront</center>
</body>
</html>
fernando@debian10x64:~/cursos/terraform-udemy-cleber$
~~~~






# ########################################################################################################################################################
# ########################################################################################################################################################
# ERRO

- Não acessível via meu dominio ainda:
<fernandomullerjr.site>

- Verificando o Whos is, parece ter alguma pendencia sobre a transferencia:
<https://who.is/whois/fernandomullerjr.site>

Registrar Info
Name
Hostinger, UAB
Whois Server
whois.hostinger.com
Referral URL
https://www.hostinger.com
Status
clientTransferProhibited https://icann.org/epp#clientTransferProhibited



clientTransferProhibited 	
client transfer prohibited
This status code tells your domain's registry to reject requests to transfer the domain from your current registrar to another.
This status indicates that it is not possible to transfer the domain name registration, which will help prevent unauthorized transfers resulting from hijacking and/or fraud. If you do want to transfer your domain, you must first contact your registrar and request that they remove this status code.


Chave secreta
  <ocultei-a-chave-secreta>
Servidores DNS
  ns-1231.awsdns-25.org ns-1645.awsdns-13.co.uk ns-229.awsdns-28.com ns-740.awsdns-28.net 



# ########################################################################################################################################################
# ########################################################################################################################################################
# SOLUÇÃO

- Desmarquei opção no painel da Hostinger:
      Bloqueio de Transferência
      Proteja facilmente seu domínio contra transferências não autorizadas

- Depois de algum tempo propagando, site acessível via domínio personalizado:
<https://fernandomullerjr.site/>





# push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 29 - Certificado SSL - ACM. pt3. TSHOOT, erros no acesso via dominio fernandomullerjr.site. Validações. Ajustes na Hostinger"
git push
git status

# PENDENTE
- Verificar billing.
- Fazer KB sobre erros desta aula.
