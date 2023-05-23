terraform {
  cloud {
    organization = "uwumarie"
    workspaces {
      name = "dns"
    }
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {}

