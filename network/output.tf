## This is only for output purposes. 

output "vpc_region" {
  value = var.vpc_region
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnets.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnets.*.id
}

output "availability_zones" {
  value = var.availability_zones
}

output "private_route_table_ids" {
  value = aws_route_table.private.*.id
}

output "vpc_ip_range" {
  value = var.vpc_ip_range
}

