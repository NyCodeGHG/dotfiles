terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.20.0"
    }
  }
}
