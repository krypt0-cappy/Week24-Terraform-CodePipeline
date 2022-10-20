#---root/main.tf---

module "networking" {
  source       = "./networking"
  vpc_cidr     = local.vpc_cidr
  public_cidrs = [for i in range(1, 255, 1) : cidrsubnet(local.vpc_cidr, 8, i)]
  access_ip    = var.access_ip
}

module "compute" {
  source        = "./compute"
  public_subnet = module.networking.public_subnet
  public_sg     = module.networking.public_sg
  key_name      = "krypt0_24_keypair"
}