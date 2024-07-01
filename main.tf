module "vpc" {
  source             = "./modules/vpc"
  for_each           = var.vpc
  cidr_block         = lookup(each.value, "cidr_block", null)
  az                 = each.value["az"]
  public_subnet_cidr = lookup(each.value, "public_subnet_cidr", null )
  web_subnet_cidr    = lookup(each.value, "web_subnet_cidr", null )
  app_subnet_cidr    = lookup(each.value, "app_subnet_cidr", null )
  db_subnet_cidr     = lookup(each.value, "db_subnet_cidr", null )

  env          = var.env
  project_name = var.project_name
}

module "rds" {
  source            = "./modules/rds"
  for_each          = var.rds
  allocated_storage = lookup(each.value, "allocated_storage", null)
  db_name           = lookup(each.value, "db_name", null)
  engine            = lookup(each.value, "engine", null)
  engine_version    = lookup(each.value, "engine_version", null)
  instance_class    = lookup(each.value, "instance_class", null)
  family            = lookup(each.value, "family", null )
  subnet_ids        = lookup(lookup(module.vpc, "main", null), "db_subnet_cidr", null)
  vpc_id            = lookup(lookup(module.vpc, "main", null ), "vpc_id", null)

  sg_cidr_block     = lookup(lookup(module.vpc, "main", null ), "app_subnets_cidr", null)

  env               = var.env
  project_name      = var.project_name
  kms_key_id        = var.kms_key_id
}