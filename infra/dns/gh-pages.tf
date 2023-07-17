resource "cloudflare_record" "awesome-prometheus-alerts-nix" {
  zone_id = local.cloudflare.zones.marie_cologne
  name = "awesome-prometheus-alerts.nix"
  type = "CNAME"
  value = "nycodeghg.github.io"
  proxied = false
}