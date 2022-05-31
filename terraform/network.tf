resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
}

resource "aws_security_group" "bosh" {
  name   = "bosh"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.bosh.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [
    "${var.cs_office_ip}/32"
  ]
}

resource "aws_security_group_rule" "agent" {
  security_group_id = aws_security_group.bosh.id
  type              = "ingress"
  from_port         = 6868
  to_port           = 6868
  protocol          = "tcp"
  cidr_blocks = [
    "${var.cs_office_ip}/32"
  ]
}

resource "aws_security_group_rule" "director" {
  security_group_id = aws_security_group.bosh.id
  type              = "ingress"
  from_port         = 25555
  to_port           = 25555
  protocol          = "tcp"
  cidr_blocks = [
    "${var.cs_office_ip}/32"
  ]
}

resource "aws_security_group_rule" "internal_tcp" {
  security_group_id = aws_security_group.bosh.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "internal_udp" {
  security_group_id = aws_security_group.bosh.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  self              = true
}

resource "aws_eip" "bosh" {
  vpc = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
