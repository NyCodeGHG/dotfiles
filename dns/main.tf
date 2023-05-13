terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {
}

locals {
  cloudflare = {
    zones = {
      nycode_dev    = "44b9454898e09be173d7d9e6fe439663"
      marie_cologne = "aa9307069abf9520bed8b74c8b2d9f73"
    }
  }
  servers = {
    artemis = "89.58.10.36"
  }
}

resource "cloudflare_record" "miniflux-nycode_dev" {
  zone_id = local.cloudflare.zones.nycode_dev
  name    = "miniflux"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "miniflux-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "miniflux"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "coder-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "coder"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "coder-wildcard-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "*.coder"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}
