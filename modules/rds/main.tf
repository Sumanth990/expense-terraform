resource "aws_db_parameter_group" "main" {
  name   = "${var.env}-${var.project_name}-pg"
  family = var.family
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-${var.project_name}-sg"
  subnet_ids = var.subnet_ids #list of subnets

  tags = {
    Name = "${var.env}-${var.project_name}-sg"
  }
}

resource "aws_security_group" "main" {
  name        = "${var.env}-${var.project_name}-rds-sg"
  description = "${var.env}-${var.project_name}-rds-sg"
  vpc_id      = var.vpc_id # We need info of VPC on which aws_security_group can be created.

  ingress {
    from_port        = 3306 #mysql runs on port no. 3306
    to_port          = 3306 #aws open port no.3306x
    protocol         = "tcp"
    cidr_blocks      = var.sg_cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env}-${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.env}-${var.project_name}-rds" #db instance needs a name
  allocated_storage    = var.allocated_storage
  db_name              = var.dbname
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = data.aws_ssm_parameter.username.value # We got the parameter and fetching it's value
  password             = data.aws_ssm_parameter.password.value
  parameter_group_name = aws_db_parameter_group.main.name # helpful in doing custom configuration.
  skip_final_snapshot  = true #When we try to delete db, it will ask to take backup to skip we are using true,in organization we require it.
  storage_encrypted    = true # always true, no question asked. In order to enable we need kms_key_id
  kms_key_id           = var.kms_key_id
  db_subnet_group_name = aws_db_subnet_group.main.name # we are exclusively telling go ahead and create in DB
  vpc_security_group_ids = [aws_security_group.main.id]
}

