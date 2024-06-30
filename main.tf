module "vpc" {
  source     = "./modules/vpc"
  for_each   = var.vpc
  cidr_block = each.value["cidr_block"]
  env        = var.env
}