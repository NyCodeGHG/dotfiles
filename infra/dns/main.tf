terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 4.17.0"
    }
  }
}

data "cloudflare_zone" "marie_cologne" {
  zone_id = local.cloudflare.zones.marie_cologne
}

data "cloudflare_zone" "nycode_dev" {
  zone_id = local.cloudflare.zones.nycode_dev
}

locals {
  records = [
    {
      zone = data.cloudflare_zone.marie_cologne
      names = [
        "marie.cologne",
        "git",
        "grafana",
        "chat",
        "matrix",
        "miniflux",
        "status",
        "nue01",
        "ip",
        "tunnel",
        "*.tunnel",
        "hydra",
        "hedgedoc",
      ]
      values = [
        {
          ip   = local.servers.artemis
          type = "v4"
        },
        {
          ip   = local.servers.artemis6
          type = "v6"
        }
      ]
    },
    {
      zone = data.cloudflare_zone.marie_cologne
      names = [
        "uptime-kuma",
        "prometheus",
        "am",
        "syncthing.artemis.marie.cologne",
        "paperless",
      ]
      values = [
        {
          ip   = local.servers.artemis-wg
          type = "v4"
        }
      ]
    },
    {
      zone = data.cloudflare_zone.nycode_dev
      names = [
        "sso",
        "grafana",
        "miniflux",
        "git",
      ]
      values = [
        {
          ip   = local.servers.artemis
          type = "v4"
        },
        {
          ip   = local.servers.artemis6
          type = "v6"
        }
      ]
    },
    {
      zone = data.cloudflare_zone.marie_cologne
      names = [
        "oci-fra01",
        "mc",
        "trwl-staging",
        "cdn",
        "minio",
        "turn",
        "db-rest",
      ]
      values = [
        {
          ip   = local.servers.delphi
          type = "v4"
        },
        {
          ip   = local.servers.delphi6
          type = "v6"
        }
      ]
    },
    {
      zone = data.cloudflare_zone.marie_cologne
      names = [
        "syncthing.delphi",
      ]
      values = [
        {
          ip   = local.servers.delphi-wg
          type = "v4"
        }
      ]
    },
  ]
  records_flat = flatten([
    for record in local.records : [
      for name in record.names : [
        for value in record.values :
        {
          key     = format("%s-%s-%s-%s", record.zone.name, name, value.ip, value.type)
          zone_id = record.zone.id
          name    = name
          value   = value.ip
          type    = value.type == "v4" ? "A" : value.type == "v6" ? "AAAA" : "ERROR"
        }
      ]
    ]
  ])
}

resource "cloudflare_record" "record" {
  for_each = { for record in local.records_flat : record.key => record }
  zone_id  = each.value.zone_id
  name     = each.value.name
  value    = each.value.value
  type     = each.value.type
}

resource "cloudflare_record" "name" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "ha"
  value   = "192.168.1.28"
  type    = "A"
}
