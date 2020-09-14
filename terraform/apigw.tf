resource "aws_api_gateway_rest_api" "attachmentsApi" {
  name           = "${terraform.workspace}-attachmentsApi"
  description    = "BPM to S3 Notify attachments API"
  api_key_source = "HEADER"
}

resource "aws_api_gateway_api_key" "attachmentsKey" {
  name = "attachmentsKey"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.attachmentsApi.id
  parent_id   = aws_api_gateway_rest_api.attachmentsApi.root_resource_id
  path_part   = "files"

}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.attachmentsApi.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.attachmentsApi.id
  stage_name  = aws_api_gateway_deployment.attachmentDeployment.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.attachmentsApi.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.attachment.invoke_arn
}

resource "aws_api_gateway_deployment" "attachmentDeployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.attachmentsApi.id
  stage_name  = "store"
}

resource "aws_api_gateway_usage_plan" "attachmentUsagePlan" {
  name = "attachment_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.attachmentsApi.id
    stage  = aws_api_gateway_deployment.attachmentDeployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.attachmentsKey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.attachmentUsagePlan.id
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.attachment.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.attachmentsApi.execution_arn}/*/*"
}

output "attachmentStoreAPIKey" {
  value = aws_api_gateway_api_key.attachmentsKey.value
}

output "apiPath" {
  value = aws_api_gateway_resource.proxy.path
}

output "attachmentStoreEndpoint" {
  value = aws_api_gateway_deployment.attachmentDeployment.invoke_url
}
