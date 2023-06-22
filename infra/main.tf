module "dns" {
  source     = "./dns"
  artemis-ip = local.artemis-ip
  delphi-ip  = module.oracle.delphi-ip
}

module "oracle" {
  source     = "./oracle"
  artemis-ip = local.artemis-ip
}

locals {
  artemis-ip = "89.58.10.36"
}
