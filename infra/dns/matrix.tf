resource "cloudflare_record" "chat-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "chat.marie.cologne"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "chat-marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "chat.marie.cologne"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}

resource "cloudflare_record" "matrix-marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "matrix.marie.cologne"
  value   = local.servers.artemis
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "matrix-marie_cologne_v6" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "matrix.marie.cologne"
  value   = local.servers.artemis6
  type    = "AAAA"
  proxied = false
}
