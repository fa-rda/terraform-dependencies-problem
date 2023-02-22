resource "aws_s3_object" "services" {
  bucket  = var.bucket
  key     = "services.txt"
  content = var.content
}
