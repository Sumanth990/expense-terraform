#subnet

#security group #allow ports

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.env}-${var.project_name}-vpc"
  }
}
