resource "cloudflare_record" "minecraft" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "mc"
  value   = local.servers.delphi
  type    = "A"
  proxied = false
}
