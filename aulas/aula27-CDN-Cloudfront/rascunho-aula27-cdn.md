
# Aula 27 - CDN - Cloudfront

# DIA 30/07/2022


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