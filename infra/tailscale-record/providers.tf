terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.17"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.19.0"
    }
  }
}
