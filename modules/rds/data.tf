data "aws_ssm_parameter" "username" {
  name = "${local.name}.rds.username"
}

data "aws_ssm_parameter" "password" {
  name = "${local.name}.rds.password"
}