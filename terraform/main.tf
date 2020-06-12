locals  {
    prefix = "${var.app}-${var.stage}"
    attachments_bucket = "${terraform.workspace}-attachments-out.${var.domain}"
}
