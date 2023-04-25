# VPC

resource "aws_vpc" "poc-infra-vpc" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name      = "poc-infra-vpc"
    Terraform = "true"
  }
}

# Subnets

## Privadas

resource "aws_subnet" "poc-infra-subnet-privada-a" {
  vpc_id            = aws_vpc.poc-infra-vpc.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "poc-infra-subnet-privada-a"
    Terraform = "true"
  }
}


resource "aws_subnet" "poc-infra-subnet-privada-b" {
  vpc_id            = aws_vpc.poc-infra-vpc.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "us-east-1b"

  tags = {
    Name      = "poc-infra-subnet-privada-b"
    Terraform = "true"
  }
}

## Publicas

resource "aws_subnet" "poc-infra-subnet-publica-a" {
  vpc_id                  = aws_vpc.poc-infra-vpc.id
  cidr_block              = "10.0.0.128/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "poc-infra-subnet-publica-a"
    Terraform = "true"
  }
}


resource "aws_subnet" "poc-infra-subnet-publica-b" {
  vpc_id                  = aws_vpc.poc-infra-vpc.id
  cidr_block              = "10.0.0.192/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name      = "poc-infra-subnet-publica-b"
    Terraform = "true"
  }
}


## Internet Gateway e Route Table Publica

resource "aws_internet_gateway" "poc-infra-igw" {
  vpc_id = aws_vpc.poc-infra-vpc.id

  tags = {
    Name      = "main"
    Terraform = "true"
  }
}

resource "aws_route_table" "publica-rt" {
  vpc_id = aws_vpc.poc-infra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc-infra-igw.id
  }

  tags = {
    Name      = "publica-rt"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "publica-rt-association-a" {
  subnet_id      = aws_subnet.poc-infra-subnet-publica-a.id
  route_table_id = aws_route_table.publica-rt.id
}

resource "aws_route_table_association" "publica-rt-association-b" {
  subnet_id      = aws_subnet.poc-infra-subnet-publica-b.id
  route_table_id = aws_route_table.publica-rt.id
}


## Nat Gateway e Route Table Publica

resource "aws_eip" "eip-ngw" {
}

resource "aws_nat_gateway" "poc-infra-nat-gw" {
  allocation_id = aws_eip.eip-ngw.id
  subnet_id     = aws_subnet.poc-infra-subnet-publica-a.id

  tags = {
    Name      = "Nat Gateway"
    Terraform = "true"
  }

  depends_on = [aws_internet_gateway.poc-infra-igw]
}

resource "aws_route_table" "privada-rt" {
  vpc_id = aws_vpc.poc-infra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.poc-infra-nat-gw.id
  }

  tags = {
    Name      = "privada-rt"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "privada-rt-association-a" {
  subnet_id      = aws_subnet.poc-infra-subnet-privada-a.id
  route_table_id = aws_route_table.privada-rt.id
}

resource "aws_route_table_association" "privada-rt-association-b" {
  subnet_id      = aws_subnet.poc-infra-subnet-privada-b.id
  route_table_id = aws_route_table.privada-rt.id
}
