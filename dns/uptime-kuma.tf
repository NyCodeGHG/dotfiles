resource "cloudflare_record" "uptime-kuma-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "uptime-kuma"
  value   = local.servers.artemis-wg
  type    = "A"
  proxied = false
}
