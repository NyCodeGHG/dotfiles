resource "cloudflare_record" "prometheus" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "prometheus"
  value   = local.servers.artemis-wg
  type    = "A"
  proxied = false
}

