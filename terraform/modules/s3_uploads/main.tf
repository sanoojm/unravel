# Uploads a file to S3
resource "aws_s3_bucket_object" "content" {

  for_each = var.content_uploads ? var.content : {}

  bucket  = var.bucket_name
  key     = each.key
  content = each.value
  etag    = md5(each.value)

}

# Uploads a file to S3
resource "aws_s3_bucket_object" "file" {

  for_each = var.file_uploads ? var.file : {}

  bucket = var.bucket_name
  key    = each.key
  source = each.value.output_path
  etag   = each.value.output_md5

}

