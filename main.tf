module "vpc" {
  source       = "./modules/vpc"
  for_each     = var.vpc
  cidr_block   = lookup(each.value, "cidr_block", null)
  az           = each.value["az"]
  public_subnet_cidr  = lookup(each.value, "public_subnet_cidr", null )
  private_subnet_cidr = lookup(each.value, "private_subnet_cidr", null )

  env          = var.env
  project_name = var.project_name
}