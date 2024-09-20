data "cloudflare_zone" "marie_cologne" {
  name = "marie.cologne"
}

data "cloudflare_zone" "nycode_dev" {
  name = "nycode.dev"
}

resource "cloudflare_record" "artemis_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  value   = "89.58.10.36"
  type    = "A"
}

resource "cloudflare_record" "artemis_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  value   = "2a03:4000:5f:f5b::"
  type    = "AAAA"
}

resource "cloudflare_record" "artemis_wg" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "wg.artemis.marie.cologne"
  value   = "10.69.0.1"
  type    = "A"
}

resource "cloudflare_record" "marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "marie.cologne"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "git_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "git"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "grafana_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "grafana"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "chat_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "chat"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "admin_chat_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "admin.chat"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "matrix_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "matrix"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "miniflux_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "miniflux"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "status_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "status"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "nue01_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "nue01"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "ip_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "ip"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "tunnel"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "wildcard_tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "*.tunnel"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "hedgedoc_tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "hedgedoc"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "sso_nycode_dev" {
  zone_id = data.cloudflare_zone.nycode_dev.id
  name    = "sso"
  value   = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "uptime-kuma_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "uptime-kuma"
  value   = "wg.artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "prometheus_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "prometheus"
  value   = "wg.artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "syncthing_artemis_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "syncthing.artemis"
  value   = "wg.artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "paperless_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "paperless"
  value   = "wg.artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "delphi_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  value   = module.oracle.delphi-ipv4
  type    = "A"
}

resource "cloudflare_record" "delphi_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  value   = "2603:c020:8012:1069:0:c0ff:ee:babe"
  type    = "AAAA"
}

resource "cloudflare_record" "oci-fra01_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "oci-fra01"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "mc_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "mc"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "cdn_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "cdn"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "minio_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "minio"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "turn_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "turn"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "syncthing_delphi_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "syncthing.delphi"
  value   = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "ha_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "ha"
  value   = "192.168.1.28"
  type    = "A"
}

resource "cloudflare_record" "awesome-prometheus-alerts-nix" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "awesome-prometheus-alerts.nix"
  type    = "CNAME"
  value   = "nycodeghg.github.io"
  proxied = false
}

resource "cloudflare_record" "ip-playground-v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v4.ip"
  value   = resource.cloudflare_record.artemis_v4.value
  type    = "A"
}

resource "cloudflare_record" "ip-playground-v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v6.ip"
  value   = resource.cloudflare_record.artemis_v6.value
  type    = "AAAA"
}
