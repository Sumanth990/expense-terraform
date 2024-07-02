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
  subnet_ids        = lookup(lookup(module.vpc, "main", null), "db_subnets_ids", null)
  vpc_id            = lookup(lookup(module.vpc, "main", null ), "vpc_id", null)

  sg_cidr_block     = lookup(lookup(module.vpc, "main", null ), "app_subnets_cidr", null)

  env               = var.env
  project_name      = var.project_name
  kms_key_id        = var.kms_key_id
}

module "backend" {
  source = "./modules/app"

  env          = var.env
  component    = "backend"
  project_name = var.project_name

  instance_capacity   = var.instance_capacity
  instance_type       = var.instance_type
  app_port            = var.app_port_backend
  bastion_block       = var.bastion_block
  vpc_id              = lookup(lookup(module.vpc, "main", null), "vpc_id", null) #module.vpc.vpc_id
  sg_cidr_blocks      = lookup(lookup(module.vpc, "main", null), "app_subnets_cidr", null)#module.vpc.app_subnets_cidr #need to check
  vpc_zone_identifier = lookup(lookup(module.vpc, "main", null), "app_subnets_ids", null)#module.vpc.app_subnets_ids
}

module "frontend" {
  source = "./modules/app"

  env          = var.env
  component    = "frontend"
  project_name = var.project_name

  instance_capacity   = var.instance_capacity
  instance_type       = var.instance_type
  app_port            = var.app_port_frontend
  bastion_block       = var.bastion_block
  vpc_id              = lookup(lookup(module.vpc, "main", null), "vpc_id", null) #module.vpc.vpc_id
  sg_cidr_blocks      = lookup(lookup(module.vpc, "main", null), "public_subnets_cidr", null)#module.vpc.app_subnets_cidr #need to check
  vpc_zone_identifier = lookup(lookup(module.vpc, "main", null), "web_subnets_ids", null)#module.vpc.app_subnets_ids
}

module "public-alb" {
  source = "./modules/alb"

  env          = var.env
  project_name = var.project_name

  alb_name         = "public"
  sg_cidr_blocks   = ["0.0.0.0/0"]
  internal         = false
  target_group_arn = lookup(lookup(module.rds, "main", null ), "target_group_arn", null)
  certificate_arn  = var.certificate_arn
  subnets  = lookup(lookup(module.vpc, "main", null), "public_subnets_ids", null)
  vpc_id   = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
}

module "private-alb" {
  source = "./modules/alb"

  env          = var.env
  project_name = var.project_name

  alb_name         = "private"
  sg_cidr_blocks   = lookup(lookup(module.vpc, "main", null), "web_subnets_cidr", null)
  internal         = true
  target_group_arn = lookup(lookup(module.rds, "main", null ), "target_group_arn", null)
  certificate_arn  = var.certificate_arn

  subnets  = lookup(lookup(module.vpc, "main", null), "app_subnets_ids", null)
  vpc_id   = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
}