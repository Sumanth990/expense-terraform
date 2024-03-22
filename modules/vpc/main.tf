resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-${var.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "subnet-${count.index}"
  }
}

resource "aws_vpc_peering_connection" "main" {
  #peer_owner_id = var.peer_owner_id # optional - In our case both the vpc are in same account, so not required
  peer_vpc_id   = data.aws_vpc.default.id #we tried to achieve one peering connection.
  vpc_id        = aws_vpc.main.id #We tried to fetch the existing default VPC info rather than hard coding it.
  auto_accept   = true

  tags = {
    Name = "${var.env}-vpc-with-default-vpc"
  }
}