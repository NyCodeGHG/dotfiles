terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>4.17"
    }
  }
  backend "s3" {
    endpoint                    = "https://s3.marie.cologne"
    key                         = "terraform.tfstate"
    region                      = "garage"
    bucket                      = "terraform"
    use_path_style              = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
  encryption {
    method "aes_gcm" "encryption" {
      keys = key_provider.pbkdf2.key
    }

    state {
      method   = method.aes_gcm.encryption
      enforced = true
    }
  }
}

module "oracle" {
  source = "./oracle"
}

