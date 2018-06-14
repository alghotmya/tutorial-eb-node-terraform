resource "aws_s3_bucket" "default" {
  bucket = "${var.bucket}"
  acl    = "private"

  # DO NOT FORCE DELETE IN PRODUCTION!!!
  force_destroy = "${var.force_destroy}"

  tags = "${var.tags}"
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${aws_s3_bucket.default.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "S3BucketELBAllowPolicy",
  "Statement": [
    {
      "Sid": "ELBAllow",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.default.arn}/AWSLogs/${var.account_id}/*",
      "Principal": {
        "AWS": [
          "033677994240"
        ]
      } 
    } 
  ]
}
POLICY
}
