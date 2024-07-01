##parameter_group_name
#resource "aws_db_parameter_group" "main" {
#  name   = "${local.name}-pg"
#  family = var.family
#}
##rds
#resource "aws_db_instance" "default" {
#  allocated_storage    = var.allocated_storage
#  db_name              = var.db_name
#  engine               = var.engine
#  engine_version       = var.engine_version
#  instance_class       = var.instance_class
#  username             =
#  password             =
#  parameter_group_name = "default.mysql8.0"
#  skip_final_snapshot  = true
#}
