env = "dev"
project_name = "expense"
kms_key_id = "arn:aws:kms:us-east-1:767398130568:key/8f8138ff-f57f-49c9-90db-f99bf7dbdc08"
bastion_block = ["172.31.38.58/32"]
certificate_arn = "arn:aws:acm:us-east-1:767398130568:certificate/9a7aec0d-813a-4eac-9bb8-70530e34abbe"
zone_id = "Z039456039ZR7HLJXDP8U"



vpc = {
  main = {
    cidr_block         = "10.10.0.0/21"
    public_subnet_cidr = ["10.10.0.0/25", "10.10.0.128/25"]
    web_subnet_cidr    = ["10.10.1.0/25", "10.10.1.128/25"]
    app_subnet_cidr    = ["10.10.2.0/25", "10.10.2.128/25"]
    db_subnet_cidr     = ["10.10.3.0/25", "10.10.3.128/25"]
    az                 = ["us-east-1a", "us-east-1b"]
  }
}

rds = {
  main = {
    allocated_storage = 10
    db_name           = "expense"
    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.t3.small"
    family            = "mysql5.7"
  }
}

#backend
app_port_backend   = 8080
instance_capacity  = 1
instance_type      = "t3.small"

app_port_frontend = 80