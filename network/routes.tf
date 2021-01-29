## Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Public Subnets - ${var.application} - ${var.environment}"
    environment = var.environment
  }
}

resource "aws_route" "public_route_internet_gw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
  count          = var.public_subnets_count
}

## Private Route Tables

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Private Subnet - ${var.application} - ${var.environment}"
    environment = var.environment
  }

  count = 3
}

resource "aws_route" "nat_gw" {
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.public_subnets_count == "1" ? aws_nat_gateway.gw[0].id : element(aws_nat_gateway.gw.*.id, count.index)
  count                  = 3
}

resource "aws_route_table_association" "private" {
  subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  count          = 3
}

