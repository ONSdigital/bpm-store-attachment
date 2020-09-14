locals {
  prefix             = "${var.app}-${var.stage}"
  attachments_bucket = "${terraform.workspace}-${var.app}-${var.stage}-out.${var.domain}"
}
