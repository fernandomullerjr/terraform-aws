
# Aula 30 - Restrição no bucket e script para buildar o website



# ########################################################################################################################################################
# ########################################################################################################################################################
#  resumo - push
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git status
git add .
git commit -m "Aula 30 - Restrição no bucket e script para buildar o website. pt1"
git push
git status




# ########################################################################################################################################################
# ########################################################################################################################################################
# 30 - Restrição no bucket e script para buildar o website




# ########################################################################################################################################################
# ########################################################################################################################################################
# S3 - Restringindo acesso manualmente via console

- Atualmente nosso bucket do S3 está público

- Nesta aula será verificado como passar o bucket para privado e montar um script para buildar o website


- Acessando o Bucket principal do site e indo na aba "Permissions", tem uma policy com as permissões atuais:

~~~~json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::fernandomullerjr.site/*"
        }
    ]
}
~~~~


- Atualmente a policy permite que todos possam obter objetos do bucket.
- Precisamos restringir o acesso aos objetos do bucket somenta para o nosso CDN.


- No Cloudfront, estava com a opção "No, I will update the bucket policy" marcada, no trecho:

Bucket policy
Update the S3 bucket policy to allow read access to the OAI.
No, I will update the bucket policy
Yes, update the bucket policy

- Marcando a opção:
Yes, update the bucket policy

- Conferindo nas permissions do bucket do S3, foi atualizada a policy:

~~~~json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::fernandomullerjr.site/*"
        },
        {
            "Sid": "2",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3IAQISOYSYNGY"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::fernandomullerjr.site/*"
        }
    ]
}
~~~~




- Com este script ainda é possível o acesso de todos.
- Vamos editar a policy, deixando o acesso somente para o Cloudfront.

~~~~json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "2",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3IAQISOYSYNGY"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::fernandomullerjr.site/*"
        }
    ]
}
~~~~



- Agora ao tentar acessar a página do Site no S3:

<http://fernandomullerjr.site.s3-website-us-east-1.amazonaws.com/>

403 Forbidden

    Code: AccessDenied
    Message: Access Denied
    RequestId: HRGXEPFF7QKKY0PF
    HostId: lsM4ub335MJGdeHg+r3tyFz9JWepuJ4Ek/JjGRGAQmU4CLdjOlgoKLBjrJ5FaZHh+TvsFN1J1jk=

An Error Occurred While Attempting to Retrieve a Custom Error Document

    Code: AccessDenied
    Message: Access Denied




- Atualizando o nosso código do React, nodeJS:

~~~~javascript
import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Manual da Digital Ocean
        </p>
        <a
          className="App-link"
          href="https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-debian-10"
          target="_blank"
          rel="noopener noreferrer"
        >
          Instalando o nodejs
        </a>
        <br/>
        <a
            className="App-link"
            href="https://github.com/fernandomullerjr/terraform-aws"
            target="_blank"
            rel="noopener noreferrer"
        >
          Github - Projeto Terraform AWS
        </a>
      </header>
    </div>
  );
}

export default App;
~~~~



- Foi colocado mais um link, para o Github:

~~~~javascript
        <br/>
        <a
            className="App-link"
            href="https://github.com/fernandomullerjr/terraform-aws"
            target="_blank"
            rel="noopener noreferrer"
        >
          Github - Projeto Terraform AWS
        </a>
~~~~






# ########################################################################################################################################################
# ########################################################################################################################################################
# S3 - Restringindo o acesso ao bucket via Terraform

- Precisamos editar o arquivo s3.tf
- Atualmente ele está assim a parte sobre policy:

~~~~h
data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars = {
    bucket_name = local.domain
  }
}
~~~~



- Atualmente o arquivo policy.json está assim:

~~~~json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    }
  ]
}
~~~~


- Pegando a estrutura da policy que criamos antes:

~~~~json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "2",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3IAQISOYSYNGY"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::fernandomullerjr.site/*"
        }
    ]
}
~~~~



- Vamos editar o arquivo policy.json, tirando o acesso público a todos e colocando o "Origin Access Identity" do nosso Cloudfront, vamos passar o valor via variável [cdn_oai]:

~~~~json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${cdn_oai}"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    }
  ]
}
~~~~






- Precisamos editar o arquivo s3.tf, colocando no template a variável [cdn_oai]:
    cdn_oai     = aws_cloudfront_origin_access_identity.this.id


- Arquivo s3.tf após o ajuste:

~~~~h
data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars = {
    bucket_name = local.domain
    cdn_oai     = aws_cloudfront_origin_access_identity.this.id
  }
}
~~~~




- Efetuando plan após ajustes:
terraform plan


- Foi necessário usar o comando abaixo, informando o caminho do arquivo hcl com as configurações do Backend:
terraform init -backend-config=backend.hcl




- Efetuando plan após ajustes:
terraform plan




~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula30-Restricao-no-bucket-e-script-para-buildar-o-website/terraform$ terraform plan
Acquiring state lock. This may take a few moments...
random_pet.website: Refreshing state... [id=frankly-internally-horribly-welcome-killdeer]
aws_acm_certificate.this[0]: Refreshing state... [id=arn:aws:acm:us-east-1:261106957109:certificate/2a21728f-2c3f-4b74-856c-8df96941b411]
aws_cloudfront_origin_access_identity.this: Refreshing state... [id=E3IAQISOYSYNGY]
module.logs.aws_s3_bucket.this: Refreshing state... [id=fernandomullerjr.site-logs]
aws_route53_record.cert_validation["fernandomullerjr.site"]: Refreshing state... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_route53_record.cert_validation["*.fernandomullerjr.site"]: Refreshing state... [id=Z0647982JAWRY25D845S__c9ed2937ec43a466e90729c949d20c4e.fernandomullerjr.site._CNAME]
aws_acm_certificate_validation.this[0]: Refreshing state... [id=2022-09-07 16:04:17.664 +0000 UTC]
module.website.aws_s3_bucket.this: Refreshing state... [id=fernandomullerjr.site]
module.website.module.objects.aws_s3_bucket_object.this["favicon.ico"]: Refreshing state... [id=favicon.ico]
module.website.module.objects.aws_s3_bucket_object.this["robots.txt"]: Refreshing state... [id=robots.txt]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.LICENSE.txt"]: Refreshing state... [id=static/js/main.d58be654.js.LICENSE.txt]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css"]: Refreshing state... [id=static/css/main.073c9b0a.css]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js]
module.website.module.objects.aws_s3_bucket_object.this["asset-manifest.json"]: Refreshing state... [id=asset-manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["index.html"]: Refreshing state... [id=index.html]
module.website.module.objects.aws_s3_bucket_object.this["static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg"]: Refreshing state... [id=static/media/logo.6ce24c58023cc2f8fd88fe9d219db6c6.svg]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js"]: Refreshing state... [id=static/js/main.d58be654.js]
module.redirect.aws_s3_bucket.this: Refreshing state... [id=www.fernandomullerjr.site]
module.website.module.objects.aws_s3_bucket_object.this["logo512.png"]: Refreshing state... [id=logo512.png]
module.website.module.objects.aws_s3_bucket_object.this["static/css/main.073c9b0a.css.map"]: Refreshing state... [id=static/css/main.073c9b0a.css.map]
module.website.module.objects.aws_s3_bucket_object.this["manifest.json"]: Refreshing state... [id=manifest.json]
module.website.module.objects.aws_s3_bucket_object.this["logo192.png"]: Refreshing state... [id=logo192.png]
module.website.module.objects.aws_s3_bucket_object.this["static/js/787.71e672d5.chunk.js.map"]: Refreshing state... [id=static/js/787.71e672d5.chunk.js.map]
module.website.module.objects.aws_s3_bucket_object.this["static/js/main.d58be654.js.map"]: Refreshing state... [id=static/js/main.d58be654.js.map]
aws_cloudfront_distribution.this: Refreshing state... [id=E3DUT01E7FPKW]
aws_route53_record.website[0]: Refreshing state... [id=Z0647982JAWRY25D845S_fernandomullerjr.site_A]
aws_route53_record.www[0]: Refreshing state... [id=Z0647982JAWRY25D845S_www.fernandomullerjr.site_A]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_cloudfront_distribution.this has changed
  ~ resource "aws_cloudfront_distribution" "this" {
      ~ etag                           = "E3LTP6DSD16WR4" -> "E34HRV13OKJVKK"
        id                             = "E3DUT01E7FPKW"
      ~ last_modified_time             = "2022-09-07 16:30:11.814 +0000 UTC" -> "2022-09-18 00:41:37.33 +0000 UTC"
        tags                           = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
        # (16 unchanged attributes hidden)





        # (5 unchanged blocks hidden)
    }

  # aws_route53_record.website[0] has changed
  ~ resource "aws_route53_record" "website" {
        id      = "Z0647982JAWRY25D845S_fernandomullerjr.site_A"
        name    = "fernandomullerjr.site"
      + records = []
      + ttl     = 0
        # (3 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

  # module.website.aws_s3_bucket.this has changed
  ~ resource "aws_s3_bucket" "this" {
        id                          = "fernandomullerjr.site"
      ~ policy                      = jsonencode(
          ~ {
              ~ Statement = [
                  ~ {
                      ~ Principal = {
                          ~ AWS = "*" -> "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3IAQISOYSYNGY"
                        }
                      ~ Sid       = "PublicReadForGetBucketObjects" -> "2"
                        # (3 unchanged elements hidden)
                    },
                ]
                # (1 unchanged element hidden)
            }
        )
        tags                        = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
        # (11 unchanged attributes hidden)



        # (3 unchanged blocks hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to
these changes.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.website.aws_s3_bucket.this will be updated in-place
  ~ resource "aws_s3_bucket" "this" {
        id                          = "fernandomullerjr.site"
      ~ policy                      = jsonencode(
          ~ {
              ~ Statement = [
                  ~ {
                      ~ Sid       = "2" -> "PublicReadForGetBucketObjects"
                        # (4 unchanged elements hidden)
                    },
                ]
                # (1 unchanged element hidden)
            }
        )
        tags                        = {
            "CreatedAt" = "2022-07-23"
            "Module"    = "3"
            "Project"   = "Curso AWS com Terraform"
            "Service"   = "Static Website"
        }
        # (11 unchanged attributes hidden)



        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
~~~~




- Antes de fazer o apply, vamos criar um script para buildar o site automaticamente.
- Criar uma pasta chamada scripts
  513  mkdir /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula30-Restricao-no-bucket-e-script-para-buildar-o-website/scripts
  514  history | tail

- Criar o script chamado deploy.sh, com o seguinte conteúdo:

~~~~bash
#!/bin/sh

set -e

cd "${0%/*}" || return

DOMAIN=""

if [ "$1" != "" ]; then
  DOMAIN="$1"
fi

echo "----------------------------------------"
echo "Creating an optimized production React App build..."
cd ../website || return
npm ci
npm run build
echo "----------------------------------------"
cd ../terraform || return
echo "Formatting terraform files"
echo "terraform fmt -recursive"
terraform fmt -recursive
echo "----------------------------------------"
echo "terraform init -backend=true -backend-config=backend.hcl"
terraform init -backend=true -backend-config="backend.hcl"
echo "----------------------------------------"
echo "Validating terraform files"
echo "terraform validate"
terraform validate
echo "----------------------------------------"
echo "Planning..."
echo "terraform plan -var=domain=$DOMAIN -out=plan.tfout"
terraform plan -var="domain=$DOMAIN" -out="plan.tfout"
echo "----------------------------------------"
echo "Applying..."
echo "terraform apply plan.tfout"
terraform apply plan.tfout
echo "----------------------------------------"
echo "Cleaning up plan file"
echo "rm -rf plan.tfout"
rm -rf plan.tfout
echo "----------------------------------------"
~~~~