resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"

  tags = local.common_tags
}

resource "aws_s3_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${local.ip_filepath}"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
    content_type = "application/json"
}

resource "aws_s3_object" "random" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/${random_pet.bucket.id}.json"
    source = local.ip_filepath
    etag = filemd5(local.ip_filepath)
    tags = local.common_tags
    content_type = "application/json"
}