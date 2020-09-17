variable "app" {
  type    = string
  default = "attachments"
}

variable "stage" {
  type = string
}

variable "logging_bucket" {
  type = string
}

variable "domain" {
  type    = string
  default = "bpm.ons.digital"
}
