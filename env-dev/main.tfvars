env = "dev"
project_name = "expense"
kms_key_id = "arn:aws:kms:us-east-1:992382357886:key/22bbbe40-97dd-4395-9d24-7953d9782528"
bastion_block = ["172.31.35.134/32"]
certificate_arn = "arn:aws:acm:us-east-1:992382357886:certificate/00edc2f5-d8d3-4524-8710-8e57ba0f5dae"
zone_id = "Z0531898YLDJ6DDU67F4"

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
    allocated_storage = 8
    db_name           = "expense"
    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.t3.micro"
    family            = "mysql5.7"
  }
}

#backend
app_port_backend   = 8080
instance_capacity  = 1
instance_type      = "t3.small"

app_port_frontend = 80