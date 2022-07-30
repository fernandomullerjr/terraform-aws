output "website-url" {
  value = local.has_domain ? var.domain : module.website.website
}