#common variables
variable "env" {}
variable "project_name" {}
variable "kms_key_id" {}
#space #individual variables
variable "vpc_cidr" {}
variable "public_subnets_cidr" {}
variable "web_subnets_cidr" {}
variable "app_subnets_cidr" {}
variable "db_subnets_cidr" {}
variable "az" {}
variable "rds_allocated_storage" {}
variable "rds_dbname" {}
variable "rds_engine" {}
variable "rds_engine_version" {}
variable "rds_family" {}
variable "rds_instance_class" {}

#space #individual variables for understanding purpose which is common and individual.
#variable "vpc" {}
#variable "rds" {}