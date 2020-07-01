locals {
  attachments_bucket = "${terraform.workspace}-${var.app}-${var.stage}-out.${var.domain}"
}
