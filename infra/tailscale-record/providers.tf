terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.25.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29.0"
    }
  }
}
