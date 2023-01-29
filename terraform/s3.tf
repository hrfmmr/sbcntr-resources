resource "aws_s3_bucket" "sbcntr_logs" {
  bucket = "sbcntr-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_acl" "sbcntr_logs" {
  bucket = aws_s3_bucket.sbcntr_logs.id
  acl    = "private"
}
