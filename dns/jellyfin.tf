resource "cloudflare_record" "jellyfin-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "jellyfin"
  value   = local.servers.artemis-wg
  type    = "A"
  proxied = false
}
