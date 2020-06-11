resource "aws_s3_bucket" "attachments" {
  bucket = local.attachments_bucket
  policy = <<-POLICY
    {
        "Version":"2012-10-17",
        "Statement":[
            {
            "Sid":"PublicRead",
            "Effect":"Allow",
            "Principal": "*",
            "Action":["s3:GetObject"],
            "Resource":["arn:aws:s3:::${local.attachments_bucket}/*"]
            }
        ]
    }
POLICY
}

resource "aws_iam_policy" "attachment-lambda-s3-policy" {
  name        = "${local.prefix}-attachment-s3-lambda"
  description = "Least privilege permissions for outgoing attachments lambda"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.attachments_bucket}/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetBucketLocation",
            "Resource": "arn:aws:s3:::${local.attachments_bucket}"
        }
    ]
}
POLICY
}
