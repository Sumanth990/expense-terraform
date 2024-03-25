output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public.*.id  #It's sends as list because there are 2 subnets.
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

#vpc_id,subnets_ids it's grounds to main vpc because we have