#subnet
resource "aws_subnet" "main" {
  count             = length(var.subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "subnet-${count.index}"
  }
}

#security group #allow ports

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${local.name}-vpc"
  }
}
