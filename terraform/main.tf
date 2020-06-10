provider "aws" {}

locals  {
    prefix = "${var.app}-${var.stage}"
    attachments_bucket = "${terraform.workspace}-attachments-out.${var.domain}"
}

terraform {
  backend "s3" {
    bucket               = "terraform.bpm.ons.digital"
    key                  = "store-attachment/lambda.tfstate"
    workspace_key_prefix = "workspaces"
  }
}