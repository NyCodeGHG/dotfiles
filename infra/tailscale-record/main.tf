data "tailscale_device" "device" {
  hostname = var.hostname
}

resource "cloudflare_record" "tailscale_record" {
  for_each = toset(data.tailscale_device.device.addresses)
  zone_id  = var.zone_id
  name     = var.name
  content  = each.key
  type     = strcontains(each.key, ":") ? "AAAA" : "A"
}
