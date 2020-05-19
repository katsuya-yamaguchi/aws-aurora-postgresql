output "s3_bucket_logging" {
  value = aws_s3_bucket.logging_katsuya_place_work.bucket
}
output "s3_bucket_assets" {
  value = aws_s3_bucket.assets_katsuya_place_work.bucket
}
