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
    cidr_block = "10.0.1.0/24"
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

resource "aws_subnet" "public" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "private-subnet-${count.index+1}"
  }
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

##testing purpose let's create a instance
data "aws_ami" "example" {
  most_recent = true
  name_regex = "Centos-8-DevOps-Practice"
  owners = ["973714476881"]
}

#terraform:resource/aws_security_group

resource "aws_security_group" "test" {
  name        = "test"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_this"
  }
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.example.image_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[0].id #lookup(element(aws_subnet.main, 0), "id", null) created VPC under this subnet
  security_groups = [aws_security_group.test.id]
  #to open port 22 we need to create security group to others [] -> expecting in a list
}