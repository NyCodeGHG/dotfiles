terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.26.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29.0"
    }
  }
}
