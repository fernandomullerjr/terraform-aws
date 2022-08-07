
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
