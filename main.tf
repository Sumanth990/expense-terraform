module "vpc" {
  source       = "./modules/vpc"
  for_each     = var.vpc
  cidr_block   = lookup(each.value, "cidr_block", null)
  az           = each.value["az"]
  subnet_cidr  = lookup(each.value, "subnet_cidr", null )

  env          = var.env
  project_name = var.project_name
}