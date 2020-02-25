# Specifies the details for the base infrastructure such as VPC, subnets, etc

resource "aws_vpc" "K8S_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name  = "${var.id}_vpc"
    Owner = var.owner
  }
}

resource "aws_subnet" "infranet" {
  vpc_id            = aws_vpc.K8S_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = var.aws_az[var.aws_region]

  tags = {
    Name  = "${var.id}_infra_net"
    Owner = var.owner
  }
}

resource "aws_subnet" "appnet" {
  vpc_id            = aws_vpc.K8S_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = var.aws_az[var.aws_region]

  tags = {
    Name  = "${var.id}_app_net"
    Owner = var.owner
  }
}

resource "aws_subnet" "mgmtnet" {
  vpc_id            = aws_vpc.K8S_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = var.aws_az[var.aws_region]

  tags = {
    Name  = "${var.id}_mgmt_net"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.K8S_vpc.id

  tags = {
    Name  = "${var.id}_igw"
    Owner = var.owner
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.K8S_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "${var.id}_pub_rt"
    Owner = var.owner
  }
}

resource "aws_route_table_association" "pubrta1" {
  subnet_id      = aws_subnet.infranet.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table_association" "pubrta2" {
  subnet_id      = aws_subnet.appnet.id
  route_table_id = aws_route_table.pubrt.id
}
