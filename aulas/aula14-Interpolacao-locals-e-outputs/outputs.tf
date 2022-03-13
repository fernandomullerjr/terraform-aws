output "bucket_name" {
  value = aws_s3_bucket.super-bucket.bucket
}

output "bucket_arn" {
  value       = aws_s3_bucket.super-bucket.arn
  description = ""
}

output "bucket_domain_name" {
  value = aws_s3_bucket.super-bucket.bucket_domain_name
}

output "ips_file_path" {
  value = "${aws_s3_bucket.super-bucket.bucket}/${aws_s3_object.objeto-do-bucket.key}"
}