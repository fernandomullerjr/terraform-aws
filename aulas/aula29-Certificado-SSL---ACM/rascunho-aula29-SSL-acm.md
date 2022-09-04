
# Aula 29 - Certificado SSL - ACM.



# ########################################################################################################################################################
# ########################################################################################################################################################
#  resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git add .
git commit -m "Aula 29 - Certificado SSL - ACM."
git push



# ########################################################################################################################################################
# ########################################################################################################################################################
# DIA 04/09/2022

- Seguindo o diagrama atual, está faltando o certificado para a nossa estrutura, para certificar que o domínio pertence a nós mesmos. Também é necessário o certificado para que o nosso site utilize HTTPS.

- Usar o serviço ACM e requisitar um certificado.

- Devido a região do certificado e recursos, foi necessário criar um alias para a região da Virginia us-east-1
- O ACM precisa que que o certificado esteja na Virginia(avaliar melhor sobre isto depois)

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




# PENDENTE
AVALIAR. - O ACM precisa que que o certificado esteja na Virginia(avaliar melhor sobre isto depois)