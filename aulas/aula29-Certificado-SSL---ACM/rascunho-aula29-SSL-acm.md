
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



 push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 29 - Certificado SSL - ACM. pt1"
git push
git status



# PENDENTE
- TSHOOT, erros durante plan e apply, devido a Zone do Route53.
- AVALIAR. - O ACM precisa que que o certificado esteja na Virginia(avaliar melhor sobre isto depois)