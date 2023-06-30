terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_record" "marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "marie.cologne"
  value   = local.servers.artemis
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "marie.cologne"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = true
}
