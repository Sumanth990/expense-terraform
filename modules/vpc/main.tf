#public subnet
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

#peering connection
resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.main.id

  tags = {
    Name = "${var.env}-vpc-with-default-vpc"
  }
}

#route entry in route table
resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

#GW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}

#route table public
resource "aws_route_table" "public" {
  count  = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "public-rt-${count.index+1}"
  }
}

#route table association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = lookup(element(aws_subnet.public, count.index), "id", null)
  route_table_id = lookup(element(aws_route_table.public, count.index), "id", null)
}

#elastic IP address
resource "aws_eip" "main" {
  count  = length(var.public_subnet_cidr)
  domain = "vpc"
}
#ngw
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidr)
  allocation_id = lookup(element(aws_eip.main, count.index), "id", null)
  subnet_id     = lookup(element(aws_subnet.public, count.index), "id", null)

  tags = {
    Name = "ngw-${count.index+1}"
  }
}

#web subnet
resource "aws_subnet" "web" {
  count             = length(var.web_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.web_subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "web-subnet-${count.index+1}"
  }
}

#route table web
resource "aws_route_table" "web" {
  count  = length(var.web_subnet_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main, count.index), "id", null)
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "web-rt-${count.index+1}"
  }
}

#route table association
resource "aws_route_table_association" "web" {
  count          = length(var.web_subnet_cidr)
  subnet_id      = lookup(element(aws_subnet.web, count.index), "id", null)
  route_table_id = lookup(element(aws_route_table.web, count.index), "id", null)
}

#app subnet
resource "aws_subnet" "app" {
  count             = length(var.app_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.app_subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "app-subnet-${count.index+1}"
  }
}

#route table web
resource "aws_route_table" "app" {
  count  = length(var.app_subnet_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main, count.index), "id", null)
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "app-rt-${count.index+1}"
  }
}

#route table association
resource "aws_route_table_association" "app" {
  count          = length(var.app_subnet_cidr)
  subnet_id      = lookup(element(aws_subnet.app, count.index), "id", null)
  route_table_id = lookup(element(aws_route_table.app, count.index), "id", null)
}


#db subnet
resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db_subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "db-subnet-${count.index+1}"
  }
}

#route table db
resource "aws_route_table" "db" {
  count  = length(var.db_subnet_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main, count.index), "id", null)
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "db-rt-${count.index+1}"
  }
}

#route table association
resource "aws_route_table_association" "db" {
  count          = length(var.db_subnet_cidr)
  subnet_id      = lookup(element(aws_subnet.db, count.index), "id", null)
  route_table_id = lookup(element(aws_route_table.db, count.index), "id", null)
}

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${local.name}-vpc"
  }
}
