locals {
  prefix             = "${var.app}-${var.stage}"
  attachments_bucket = "${var.dns}-${var.app}-${var.stage}-out.${var.domain}"
}
