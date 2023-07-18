resource "cloudflare_record" "ip-playground-v4" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "v4.ip"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "ip-playground-v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "v6.ip"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}
