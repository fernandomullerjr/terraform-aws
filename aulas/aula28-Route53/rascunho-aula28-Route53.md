
# Aula 28 - Route 53

# resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git add .
git commit -m "Aula 28 - Route 53 - Site estático"
git push

# DIA 07/08/2022


- Comando curl que traz o tempo de resposta de um site:
curl -o /dev/null -s -w %{time_total}\n  http://www.dailymotion.com
curl -o /dev/null -s -w %{time_total}\n  http://manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com/

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ curl -o /dev/null -s -w %{time_total}\n  http://manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com/
0.362089n
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$ cat | curl -o /dev/null -s -w %{time_total}\n  http://manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com/
0.383992n
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula26-buckets/terraform$


- Acessando via browser:
http://manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com/
- Tempo levado:
357ms



# Cloudfront

- Acessar o arquivo s3.tf e adicionar as tags nos buckets:
    tags          = local.common_tags

- Criando arquivo cloudfront.tf na pasta terraform do projeto.
cloudfront.tf

~~~~h
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = local.domain
}
~~~~


- Adicionando um local regional_domain ao arquivo locals.tf, que vai ser usado na configuração do Cloudfront:
regional_domain  = module.website.regional_domain_name




- Vamos encaminhar o Header com o Origin
    headers      = ["Origin"]

- Nos Cookies não vamos passar nada para frente:
    forward = "none"

- Vamos definir nosso Origin:
    domain_name = local.regional_domain
    origin_id   = local.regional_domain

- Não vamos definir restrições de acesso por geolocalização:
    restriction_type = "none"

- Vamos usar um certificado do próprio Cloudfront:
    dynamic "viewer_certificate" {
    for_each = local.has_domain ? [] : [0]
    content {
      cloudfront_default_certificate = true
    }

- Adicionar as tags no Cloudfront também:
    tags = local.common_tags


- Configuração vai ficar assim

~~~~h
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = local.domain
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"
  aliases             = local.has_domain ? [local.domain] : []

  logging_config {
    bucket          = module.logs.domain_name
    prefix          = "cnd/"
    include_cookies = true
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.regional_domain
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1h
    max_ttl                = 86400 # 1d

    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = local.regional_domain
    origin_id   = local.regional_domain

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [] : [0]
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [0] : []
    content {
      acm_certificate_arn = aws_acm_certificate.this[0].arn
      ssl_support_method  = "sni-only"
    }
  }

  tags = local.common_tags
}
~~~~




terraform fmt -recursive
# Pendente
- Destroy










─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_cloudfront_distribution.this will be created
  + resource "aws_cloudfront_distribution" "this" {
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
          + target_origin_id       = "manually-locally-repeatedly-hot-reindeer.s3.amazonaws.com"
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
          + bucket          = "manually-locally-repeatedly-hot-reindeer-logs.s3.amazonaws.com"
          + include_cookies = true
          + prefix          = "cnd/"
        }

      + origin {
          + domain_name = "manually-locally-repeatedly-hot-reindeer.s3.amazonaws.com"
          + origin_id   = "manually-locally-repeatedly-hot-reindeer.s3.amazonaws.com"

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
          + cloudfront_default_certificate = true
          + minimum_protocol_version       = "TLSv1"
        }
    }

  # aws_cloudfront_origin_access_identity.this will be created
  + resource "aws_cloudfront_origin_access_identity" "this" {
      + caller_reference                = (known after apply)
      + cloudfront_access_identity_path = (known after apply)
      + comment                         = "manually-locally-repeatedly-hot-reindeer"
      + etag                            = (known after apply)
      + iam_arn                         = (known after apply)
      + id                              = (known after apply)
      + s3_canonical_user_id            = (known after apply)
    }

  # module.logs.aws_s3_bucket.this will be updated in-place
  ~ resource "aws_s3_bucket" "this" {
        id                          = "manually-locally-repeatedly-hot-reindeer-logs"
      ~ tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
        # (9 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

  # module.redirect.aws_s3_bucket.this will be updated in-place
  ~ resource "aws_s3_bucket" "this" {
        id                          = "www.manually-locally-repeatedly-hot-reindeer"
      ~ tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
        # (11 unchanged attributes hidden)


        # (2 unchanged blocks hidden)
    }

  # module.website.aws_s3_bucket.this will be updated in-place
  ~ resource "aws_s3_bucket" "this" {
        id                          = "manually-locally-repeatedly-hot-reindeer"
      ~ tags                        = {
          + "CreatedAt" = "2022-07-23"
          + "Module"    = "3"
          + "Project"   = "Curso AWS com Terraform"
          + "Service"   = "Static Website"
        }
        # (12 unchanged attributes hidden)



        # (3 unchanged blocks hidden)
    }

Plan: 2 to add, 3 to change, 0 to destroy.






terraform fmt -recursive
terraform fmt -recursive
terraform fmt -recursive
terraform fmt -recursive

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$ terraform fmt -recursive
locals.tf
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$


terraform apply -auto-approve
terraform apply -auto-approve
terraform apply -auto-approve

- Apply efetuado:

~~~~bash
Plan: 2 to add, 3 to change, 0 to destroy.
aws_cloudfront_origin_access_identity.this: Creating...
module.logs.aws_s3_bucket.this: Modifying... [id=manually-locally-repeatedly-hot-reindeer-logs]
aws_cloudfront_origin_access_identity.this: Creation complete after 2s [id=ETL7A7287L6IR]
module.logs.aws_s3_bucket.this: Modifications complete after 10s [id=manually-locally-repeatedly-hot-reindeer-logs]
module.website.aws_s3_bucket.this: Modifying... [id=manually-locally-repeatedly-hot-reindeer]
module.website.aws_s3_bucket.this: Still modifying... [id=manually-locally-repeatedly-hot-reindeer, 10s elapsed]
module.website.aws_s3_bucket.this: Modifications complete after 11s [id=manually-locally-repeatedly-hot-reindeer]
module.redirect.aws_s3_bucket.this: Modifying... [id=www.manually-locally-repeatedly-hot-reindeer]
aws_cloudfront_distribution.this: Creating...
module.redirect.aws_s3_bucket.this: Still modifying... [id=www.manually-locally-repeatedly-hot-reindeer, 10s elapsed]
aws_cloudfront_distribution.this: Still creating... [10s elapsed]
module.redirect.aws_s3_bucket.this: Modifications complete after 11s [id=www.manually-locally-repeatedly-hot-reindeer]
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
aws_cloudfront_distribution.this: Creation complete after 2m58s [id=E1BZBJYKA7I358]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 2 added, 3 changed, 0 destroyed.

Outputs:

website-url = "manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$
~~~~




- Endereço do CDN
https://d18su16wdxqhzq.cloudfront.net/


- Comando curl que traz o tempo de resposta de um site:
curl -o /dev/null -s -w %{time_total}\n  http://www.dailymotion.com
curl -o /dev/null -s -w %{time_total}\n  http://manually-locally-repeatedly-hot-reindeer.s3-website-us-east-1.amazonaws.com/
curl -o /dev/null -s -w %{time_total}\n  https://d18su16wdxqhzq.cloudfront.net/


cat | curl -o /dev/null -s -w %{time_total}\n  https://d18su16wdxqhzq.cloudfront.net/

fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$ cat | curl -o /dev/null -s -w %{time_total}\n  https://d18su16wdxqhzq.cloudfront.net/
0.118271n
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$




Destroy complete! Resources: 21 destroyed.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$




# PENDENTE
- Destroy
- aula continua em 7:34
- aula continua em 7:34
- aula continua em 7:34





# Dia 07/08/2022

- Adicionando ao outputs.tf:

~~~~h
output "cdn-url" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "distribution-id" {
  value = aws_cloudfront_distribution.this.id
}
~~~~



- Como a gente não tem um dominio personalizado, podemos usar um certificado fornecido pelo Cloudfront.
- Basta usar o cloudfront_default_certificate como "true":

~~~~h
  dynamic "viewer_certificate" {
    for_each = local.has_domain ? [] : [0]
    content {
      cloudfront_default_certificate = true
    }
  }
~~~~




- Efetuando plan


Plan: 21 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cdn-url         = (known after apply)
  + distribution-id = (known after apply)
  + website-url     = (known after apply)



- Observação:
a ordem do HEAD, GET e OPTIONS importa, na configuração do Cloudfront:

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET"]


- Efetuando apply
terraform apply -auto-approve

~~~~bash
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

cdn-url = "dd8gecyr9fae5.cloudfront.net"
distribution-id = "E18OGVTNZBEKXE"
website-url = "mainly-gladly-mistakenly-modern-crayfish.s3-website-us-east-1.amazonaws.com"
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula27-CDN-Cloudfront/terraform$
~~~~





- Acessando o F12, nos cabeçalhos da requisição é possível verificar se o acesso foi via Cloudfront ou não.
- Verificar o campo "x-cache", deve conter "Miss from cloudfront" quando não estar cacheado ainda ou "Hit from cloudfront" quando for via CDN/estiver cacheado.
x-cache 	Hit from cloudfront