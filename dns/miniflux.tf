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

