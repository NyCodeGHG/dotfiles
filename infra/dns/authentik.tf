resource "cloudflare_record" "authentik-nycode_dev" {
  zone_id = local.cloudflare.zones.nycode_dev
  name    = "sso"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "authentik-nycode_dev_v6" {
  zone_id = local.cloudflare.zones.nycode_dev
  name    = "sso"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}
