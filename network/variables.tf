variable "vpc_region" {
  default = "us-east-1"
}

variable "application" {}

variable "environment" {}

variable "vpc_ip_range" {
  type = list(string)
  default = ["10.10.0.0/16"]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.10.1.0/24","10.10.2.0/24","10.10.3.0/24"]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.10.4.0/24","10.10.5.0/24","10.10.6.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}

variable "public_subnets_count" {
  default = 3
}

variable "private_subnets_count" {
  default = 3
}

variable "nat_count" {
  default = 3
}

