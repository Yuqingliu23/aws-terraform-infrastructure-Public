data "aws_vpc" "existing" {
  count = 0
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

locals {
  vpc_id = aws_vpc.main.id
}

data "aws_subnet" "existing_public" {
  count  = 0
  vpc_id = local.vpc_id
  tags = {
    Name = "${var.vpc_name}-public"
  }
}

data "aws_subnet" "existing_private" {
  count  = 0
  vpc_id = local.vpc_id
  tags = {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.vpc_name}-private"
  }
}

locals {
  public_subnet_id  = aws_subnet.public.id
  private_subnet_id = aws_subnet.private.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = local.public_subnet_id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = local.private_subnet_id
  route_table_id = aws_route_table.private.id
}
