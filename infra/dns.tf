data "cloudflare_zone" "marie_cologne" {
  name = "marie.cologne"
}

data "cloudflare_zone" "nycode_dev" {
  name = "nycode.dev"
}

resource "cloudflare_record" "artemis_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  content = "89.58.10.36"
  type    = "A"
}

resource "cloudflare_record" "dn42_endpoint" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "dn42-de.marie.cologne"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "artemis_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "artemis.marie.cologne"
  content = "2a03:4000:5f:f5b::"
  type    = "AAAA"
}

resource "cloudflare_record" "artemis_wg" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "wg.artemis.marie.cologne"
  content = "10.69.0.1"
  type    = "A"
}

resource "cloudflare_record" "marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "marie.cologne"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "cache_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "cache"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "iplookupd_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "iplookupd"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "kanidm" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "idm.marie.cologne"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}


resource "cloudflare_record" "git_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "git"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "grafana_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "grafana"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "chat_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "chat"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "admin_chat_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "admin.chat"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "matrix_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "matrix"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "miniflux_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "miniflux"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "status_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "status"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "nue01_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "nue01"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "ip_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "ip"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "tunnel"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "wildcard_tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "*.tunnel"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "hedgedoc_tunnel_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "hedgedoc"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "sso_nycode_dev" {
  zone_id = data.cloudflare_zone.nycode_dev.id
  name    = "sso"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "atuin_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "atuin"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "hydra_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "hydra"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "s3_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "s3"
  content = "artemis.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "marie_nas_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "marie-nas"
  content = "192.168.1.21"
  type    = "A"
}

resource "cloudflare_record" "jellyfin_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "jellyfin"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "jellyseerr_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "jellyseerr"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "bt_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name = "bt"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "bitmagnet_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name = "bitmagnet"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "prowlarr_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name = "prowlarr"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "sonarr_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name = "sonarr"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "hass_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "hass"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "mqtt_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "mqtt.home"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "zigbee2mqtt_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "zigbee2mqtt.home"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "matter-hub_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "matter-hub.home"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "auth_marie_nas_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "auth.marie-nas"
  content = "marie-nas.marie.cologne"
  type    = "CNAME"
}

module "prometheus_record" {
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = "prometheus"
  hostname = "artemis"
}

module "paperless_record" {
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = "paperless"
  hostname = "artemis"
}

module "cdio_record" {
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = "cdio"
  hostname = "artemis"
}

module "artemis_syncthing_record" {
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = "syncthing.artemis"
  hostname = "artemis"
}

module "artemis_logs_record" {
  source   = "./tailscale-record"
  zone_id  = data.cloudflare_zone.marie_cologne.id
  name     = "logs.artemis"
  hostname = "artemis"
}

resource "cloudflare_record" "delphi_v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  content = module.oracle.delphi-ipv4
  type    = "A"
}

resource "cloudflare_record" "delphi_v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "delphi"
  content = "2603:c020:8012:1069:0:c0ff:ee:babe"
  type    = "AAAA"
}

resource "cloudflare_record" "oci-fra01_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "oci-fra01"
  content = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "cdn_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "cdn"
  content = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "turn_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "turn"
  content = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "syncthing_delphi_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "syncthing.delphi"
  content = "delphi.marie.cologne"
  type    = "CNAME"
}

resource "cloudflare_record" "ha_marie_cologne" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "ha"
  content = "192.168.1.28"
  type    = "A"
}

resource "cloudflare_record" "awesome-prometheus-alerts-nix" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "awesome-prometheus-alerts.nix"
  type    = "CNAME"
  content = "nycodeghg.github.io"
  proxied = false
}

resource "cloudflare_record" "ip-playground-v4" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v4.ip"
  content = resource.cloudflare_record.artemis_v4.content
  type    = "A"
}

resource "cloudflare_record" "ip-playground-v6" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "v6.ip"
  content = resource.cloudflare_record.artemis_v6.content
  type    = "AAAA"
}

resource "cloudflare_record" "pronouns" {
  zone_id = data.cloudflare_zone.marie_cologne.id
  name    = "pronouns"
  content = "she/her"
  type    = "TXT"
}
