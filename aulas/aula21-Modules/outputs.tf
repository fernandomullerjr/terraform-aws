output "bucket-name" {
  value = module.bucket.name
}

output "bucket-arn" {
  value = module.bucket.arn
}

output "bucket-website-name" {
  value = module.website.name
}

output "bucket-website-url" {
  value = module.website.website
}

output "bucket-website-arn" {
  value = module.website.arn
}

output "bucket-website-files" {
  value = module.website.files
}


#
# Testes, fernando
#
output "teste_files_15_04_2022_da_raiz" {
  value = module.website.teste_files_15_04_2022
}

output "pegando_file_path_apartir_da_raiz" {
  value = module.website.pegando_file_path
}