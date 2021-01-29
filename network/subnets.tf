## Private subnets

resource "aws_subnet" "private-subnets" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = var.private_subnets_count

  tags = {
    Name        = "private-${var.application}-${element(var.availability_zones, count.index)}-${var.environment}"
    environment = var.environment
  }
}

## Public subnets

resource "aws_subnet" "public-subnets" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = var.public_subnets_count

  tags = {
    Name        = "public-${var.application}-${element(var.availability_zones, count.index)}-${var.environment}"
    environment = var.environment
  }
}

