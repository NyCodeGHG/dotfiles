module "dns" {
  source       = "./dns"
  artemis-ipv4 = local.artemis-ipv4
  artemis-ipv6 = local.artemis-ipv6
  delphi-ip    = module.oracle.delphi-ip
}

module "oracle" {
  source     = "./oracle"
  artemis-ip = local.artemis-ipv4
}

locals {
  artemis-ipv4 = "89.58.10.36"
  artemis-ipv6 = "2a03:4000:5f:f5b::"
}
