resource "cloudflare_record" "uptime-kuma-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "uptime-kuma"
  value   = local.servers.artemis-wg
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "status-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "status"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "status-marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "status"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}
