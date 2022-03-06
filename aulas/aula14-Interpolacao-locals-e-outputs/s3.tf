resource "aws_s3_bucket" "super-bucket" {
  bucket = "${random_pet.bucket.id}-${var.environment}"

  tags = local.common_tags
}

resource "aws_s3_bucket_object" "objeto-do-bucket" {
    bucket = aws_s3_bucket.super-bucket.bucket
    key = "config/ips.json"
    source = "ips.json"
    etag = filemd5("ips.json")
}