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
