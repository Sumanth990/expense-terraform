env          = "dev"
project_name = "expense"
kms_key_id   = "arn:aws:kms:us-east-1:058264064379:key/f00abcaa-673e-4ddf-8aad-e27446a55996"

#vpc = {                             ## for each
#  main = {                          ## key
#    vpc_cidr = "10.10.0.0/21"       ##value
#    public_subnets_cidr = ["10.10.0.0/25", "10.10.0.128/25"]
#    web_subnets_cidr = ["10.10.1.0/25", "10.10.1.128/25"]
#    app_subnets_cidr = ["10.10.2.0/25", "10.10.2.128/25"]
#    db_subnets_cidr = ["10.10.3.0/25", "10.10.3.128/25"]
#    az = ["us-east-1a", "us-east-1b"]
#  }
#}
#
#rds = {
#  main = {
#    allocated_storage = 10
#    db_name           = "expense"
#    engine            = "mysql"
#    engine_version    = "5.7"
#    family            = "mysql5.7"
#    instance_class    = "db.t3.micro"
#  }
#}

vpc_cidr = "10.10.0.0/21"
public_subnets_cidr = ["10.10.0.0/25", "10.10.0.128/25"]
web_subnets_cidr    = ["10.10.1.0/25", "10.10.1.128/25"]
app_subnets_cidr    = ["10.10.2.0/25", "10.10.2.128/25"]
db_subnets_cidr     = ["10.10.3.0/25", "10.10.3.128/25"]
az                  = ["us-east-1a", "us-east-1b"]

rds_allocated_storage = 10
rds_dbname            = "expense"
rds_engine            = "mysql"
rds_engine_version    = "5.7"
rds_family            = "mysql5.7" #If one more rds requirement came into picture like new family eg:mysql10.4, we need to struggle a lot
rds_instance_class    = "db.t3.micro"