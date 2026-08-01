data "cloudflare_zone" "marie_cologne" {
  filter = {
    name = "marie.cologne"
  }
}

data "cloudflare_zone" "nycode_dev" {
  filter = {
    name = "nycode.dev"
  }
}

locals {
  artemis_cnames = toset([
    "cache", "irc", "tsp", "iplookupd",
    "git", "grafana", "chat", "admin.chat",
    "matrix", "miniflux", "nue01",
    "ip", "hedgedoc",
    "atuin", "hydra", "s3", "*.s3", "s3-web",
    "idm.marie.cologne", "dn42-de.marie.cologne",
  ])

  marie_nas_cnames = toset([
    "jellyfin", "immich", "bt", "bitmagnet",
    "prowlarr", "sonarr", "radarr", "bazarr", "hass", "mass",
    "mqtt.home", "esphome.home", "matter-hub.home", "matterjs.home",
    "auth.marie-nas", "z2m.home", "sab",
  ])

  delphi_cnames = toset([
    "oci-fra01", "syncthing.delphi",
  ])
}

module "tailscale_records" {
  for_each = {
    "prometheus"        = "artemis"
    "paperless"         = "artemis"
    "syncthing.artemis" = "artemis"
    "logs.artemis"      = "artemis"
    "metrics.artemis"   = "artemis"
  }
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = each.key
  hostname = each.value
}

resource "cloudflare_dns_record" "artemis_cnames" {
  for_each = local.artemis_cnames
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = each.value
  content  = "artemis.marie.cologne"
  type     = "CNAME"
  ttl      = 1
}

resource "cloudflare_dns_record" "marie_nas_cnames" {
  for_each = local.marie_nas_cnames
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = each.value
  content  = "marie-nas.marie.cologne"
  type     = "CNAME"
  ttl      = 1
}

resource "cloudflare_dns_record" "delphi_cnames" {
  for_each = local.delphi_cnames
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = each.value
  content  = "delphi.marie.cologne"
  type     = "CNAME"
  ttl      = 1
}

resource "cloudflare_dns_record" "artemis_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  content = "89.58.10.36"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "artemis_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  content = "2a03:4000:5f:f5b::1"
  type    = "AAAA"
  ttl     = 1
}

resource "cloudflare_dns_record" "marie_nas_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "marie-nas"
  content = "192.168.1.21"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "delphi_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  content = "141.144.240.28"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "delphi_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  content = "2603:c020:8012:1069:0:c0ff:ee:babe"
  type    = "AAAA"
  ttl     = 1
}

resource "cloudflare_dns_record" "marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "marie.cologne"
  content = "artemis.marie.cologne"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_dns_record" "sso_nycode_dev" {
  zone_id = data.cloudflare_zone.nycode_dev.id
  name    = "sso"
  content = "artemis.marie.cologne"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_dns_record" "awesome-prometheus-alerts-nix" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "awesome-prometheus-alerts.nix"
  type    = "CNAME"
  content = "nycodeghg.github.io"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "ip-playground-v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v4.ip"
  content = resource.cloudflare_dns_record.artemis_v4.content
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "ip-playground-v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v6.ip"
  content = resource.cloudflare_dns_record.artemis_v6.content
  type    = "AAAA"
  ttl     = 1
}

resource "cloudflare_dns_record" "pronouns" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "pronouns"
  content = "she/her"
  type    = "TXT"
  ttl     = 1
}
