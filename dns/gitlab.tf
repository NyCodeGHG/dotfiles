resource "cloudflare_record" "git-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "git"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "git-nycode_dev" {
  zone_id = local.cloudflare.zones.nycode_dev
  name    = "git"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}
