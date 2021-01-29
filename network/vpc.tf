# VPC creation for given IP Range
resource "aws_vpc" "main" {
  cidr_block = join(",", var.vpc_ip_range)

  tags = {
    Name        = "${var.application}-${var.environment}"
    environment = var.environment
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
  domain_name         = "ec2.internal"
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

