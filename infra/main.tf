module "dns" {
  source       = "./dns"
  artemis-ipv4 = local.artemis-ipv4
  artemis-ipv6 = local.artemis-ipv6
  delphi-ipv4 = module.oracle.delphi-ipv4
  delphi-ipv6 = "2603:c020:8012:1069:0:c0ff:ee:babe"
}

module "oracle" {
  source     = "./oracle"
  artemis-ip = local.artemis-ipv4
}

locals {
  artemis-ipv4 = "89.58.10.36"
  artemis-ipv6 = "2a03:4000:5f:f5b::"
}

terraform {
  backend "s3" {
    endpoint = "https://minio.marie.cologne"
    key = "terraform.tfstate"
    region = "eu-frankfurt"
    bucket = "terraform"
    force_path_style = true
    skip_region_validation = true
    skip_metadata_api_check = true
    skip_credentials_validation = true
  }
  encryption {
    method "aes_gcm" "encryption" {
      keys = key_provider.pbkdf2.key
    }

    state {
      method = method.aes_gcm.encryption
      enforced = true
    }
  }
}

