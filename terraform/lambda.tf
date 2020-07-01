resource "aws_iam_role" "attachment_lambda" {
  name = "${terraform.workspace}-${var.stage}-attachments"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow"
            }
        ]
    }
EOF
}

resource "aws_iam_role_policy_attachment" "add_cloudwatch" {
  role       = aws_iam_role.attachment_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "add_s3" {
  role       = aws_iam_role.attachment_lambda.name
  policy_arn = aws_iam_policy.attachment-lambda-s3-policy.arn
}

resource "aws_lambda_function" "attachment" {
  filename      = "../../generated/function.zip"
  runtime       = "python3.8"
  role          = aws_iam_role.attachment_lambda.arn
  function_name = "${terraform.workspace}-file-store"
  handler       = "lambda_function.lambda_handler"
  description   = "BPM Prices Correspondence outgoing attachment store"
  timeout       = 30

  environment {
    variables = {
      ATTACHMENT_BUCKET = local.attachments_bucket
    }
  }
}
