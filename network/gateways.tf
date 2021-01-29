##  Internet Gateway

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "IGW - ${var.application} - ${var.environment}"
    environment = var.environment
  }
}

## EIP

resource "aws_eip" "nat" {
  vpc   = true
  count = var.nat_count

  tags = {
    Name        = "NAT - ${var.application} - ${var.environment}"
    environment = var.environment
  }
}

## NAT Gateways

resource "aws_nat_gateway" "gw" {
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, count.index)
  count         = var.nat_count

  depends_on = [aws_internet_gateway.default]

  tags = {
    Name        = "NAT - ${var.application} - ${var.environment}"
    environment = var.environment
  }
}

