variable "hostname" {
  type        = string
  nullable    = false
  description = "Hostname of the tailnet member"
}

variable "zone_id" {
  type        = string
  nullable    = false
  description = "Cloudflare zone id"
}

variable "name" {
  type        = string
  nullable    = false
  description = "DNS record name"
}
