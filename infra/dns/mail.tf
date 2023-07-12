resource "cloudflare_record" "mail_spf" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 a mx include:spf.mail.farfrom.earth ~all"
}

resource "cloudflare_record" "mail_dkim" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "postal-hTtc7U._domainkey.marie.cologne"
  type    = "TXT"
  value   = "v=DKIM1; t=s; h=sha256; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD17YLWjZhJCit1HvD3y9nQY8crxigTHFhmMkVOKYhopp98PKtPZ4T/cHPs/72kIzE52BX3iaRC3EKZR8nujjPD2qNy95n+b3ZhY19K6f6zsZTi2xTfcvdO4MQJMoDmX8jd8Ddyl6SpXtK5UvLoE7y5LhbyQqcuv989W3olJJBjbwIDAQAB;"
}

resource "cloudflare_record" "mail_return_path" {
  zone_id = local.cloudflare.zones.marie_cologne
  name    = "psrp"
  type    = "CNAME"
  value   = "rp.mail.farfrom.earth"
}
