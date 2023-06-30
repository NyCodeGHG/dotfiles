resource "cloudflare_record" "coder-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "coder"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "coder-marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "coder"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}

resource "cloudflare_record" "coder-wildcard-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "*.coder"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "coder-wildcard-marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "*.coder"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}
