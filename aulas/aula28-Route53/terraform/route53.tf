data "aws_route53_zone" "this" {
  count = local.has_domain ? 1 : 0

  name = "${local.domain}."
}

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
