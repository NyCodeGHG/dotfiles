locals {
  cloudflare = {
    zones = {
      nycode_dev    = "44b9454898e09be173d7d9e6fe439663"
      marie_cologne = "aa9307069abf9520bed8b74c8b2d9f73"
    }
  }
  servers = {
    artemis    = var.artemis-ip
    artemis-wg = "10.69.0.1"
    delphi     = var.delphi-ip
  }
}

variable "delphi-ip" {
  type = string
}

variable "artemis-ip" {
  type = string
}
