output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public.*.id
}

output "web_subnets_ids" {
  value = aws_subnet.web.*.id
}

output "app_subnets_ids" {
  value = aws_subnet.app.*.id
}

output "db_subnets_ids" {
  value = aws_subnet.db.*.id
}

output "web_subnets_cidr" {
  value = aws_subnet.web.*.cidr_block
}

output "app_subnets_cidr" {
  value = aws_subnet.app.*.cidr_block
}

output "public_subnets_cidr" {
  value = aws_subnet.public.*.cidr_block
}

output "db_subnets_cidr" {
  value = aws_subnet.db.*.cidr_block
}