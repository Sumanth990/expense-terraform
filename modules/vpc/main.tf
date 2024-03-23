resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-${var.project_name}-vpc"
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

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block # for default vpc we are creating peering connection
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id # before creating association we need to create peering connection
  }

  tags = {
    Name = "public-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "public" { # this route table will be associated to public subnet
  count = length(var.public_subnets_cidr) # two route tables
  route_table_id = lookup(element(aws_route_table.public,count.index), "id", null) #aws_route_table.public [count.index].id
  subnet_id = lookup(element(aws_subnet.public,count.index), "id", null)
}

resource "aws_eip" "main" {
  count      = length(var.public_subnets_cidr)
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnets_cidr)
  allocation_id = lookup(element(aws_eip.main, count.index), "id", null)
  subnet_id     = lookup(element(aws_subnet.public, count.index), "id", null)

  tags = {
    Name = "ngw-${count.index+1}"
  }
}

resource "aws_subnet" "public" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "web" {
  count      = length(var.web_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.web_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "web-subnet-${count.index+1}"
  }
}

  resource "aws_route_table" "web" {
    count = length(var.web_subnets_cidr)
    vpc_id = aws_vpc.main.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = lookup(element(aws_nat_gateway.main,count.index), "id", null)
    }

    route {
      cidr_block                =  data.aws_vpc.default.cidr_block # for default vpc we are creating peering connection
      vpc_peering_connection_id = aws_vpc_peering_connection.main.id # before creating association we need to create peering connection
    }

    tags = {
      Name = "web-rt-${count.index+1}"
    }
  }

  resource "aws_route_table_association" "web" { # this route table will be associated to public subnet
    count = length(var.web_subnets_cidr) # two route tables
    route_table_id = lookup(element(aws_route_table.web,count.index), "id", null) #aws_route_table.private [count.index].id
    subnet_id = lookup(element(aws_subnet.web,count.index), "id", null)
  }

resource "aws_subnet" "web" {
  count      = length(var.web_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.web_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "web-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "web" {
  count = length(var.web_subnets_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main,count.index), "id", null)
  }

  route {
    cidr_block                =  data.aws_vpc.default.cidr_block # for default vpc we are creating peering connection
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id # before creating association we need to create peering connection
  }

  tags = {
    Name = "web-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "web" { # this route table will be associated to public subnet
  count = length(var.web_subnets_cidr) # two route tables
  route_table_id = lookup(element(aws_route_table.web,count.index), "id", null) #aws_route_table.private [count.index].id
  subnet_id = lookup(element(aws_subnet.web,count.index), "id", null)
}

resource "aws_subnet" "app" {
  count      = length(var.app_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.app_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "app-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "app" {
  count = length(var.app_subnets_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main,count.index), "id", null)
  }

  route {
    cidr_block                =  data.aws_vpc.default.cidr_block # for default vpc we are creating peering connection
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id # before creating association we need to create peering connection
  }

  tags = {
    Name = "app-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "app" { # this route table will be associated to public subnet
  count = length(var.app_subnets_cidr) # two route tables
  route_table_id = lookup(element(aws_route_table.app,count.index), "id", null) #aws_route_table.private [count.index].id
  subnet_id = lookup(element(aws_subnet.app,count.index), "id", null)
}

resource "aws_subnet" "db" {
  count      = length(var.db_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.db_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "db-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "db" {
  count = length(var.db_subnets_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = lookup(element(aws_nat_gateway.main,count.index), "id", null)
  }

  route {
    cidr_block                =  data.aws_vpc.default.cidr_block # for default vpc we are creating peering connection
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id # before creating association we need to create peering connection
  }

  tags = {
    Name = "db-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "db" { # this route table will be associated to public subnet
  count = length(var.db_subnets_cidr) # two route tables
  route_table_id = lookup(element(aws_route_table.db,count.index), "id", null) #aws_route_table.private [count.index].id
  subnet_id = lookup(element(aws_subnet.db,count.index), "id", null)
}

resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = data.aws_vpc.default.cidr_block #Peering connection to default VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
