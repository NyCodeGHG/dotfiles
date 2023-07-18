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
