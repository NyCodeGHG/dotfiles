locals {
  cloudflare = {
    zones = {
      nycode_dev    = "44b9454898e09be173d7d9e6fe439663"
      marie_cologne = "aa9307069abf9520bed8b74c8b2d9f73"
    }
  }
  servers = {
    artemis    = var.artemis-ipv4
    artemis6   = var.artemis-ipv6
    artemis-wg = "10.69.0.1"
    delphi     = var.delphi-ipv4
    delphi6    = var.delphi-ipv6
    delphi-wg  = "10.69.0.7"
  }
}

variable "delphi-ipv4" {
  type = string
}

variable "delphi-ipv6" {
  type = string
}

variable "artemis-ipv4" {
  type = string
}

variable "artemis-ipv6" {
  type = string
}
