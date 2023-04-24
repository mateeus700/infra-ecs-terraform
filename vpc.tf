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
  availability_zone = "us-east-2a"

  tags = {
    Name      = "poc-infra-subnet-privada-a"
    Terraform = "true"
  }
}


resource "aws_subnet" "poc-infra-subnet-privada-b" {
  vpc_id            = aws_vpc.poc-infra-vpc.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "us-east-2b"

  tags = {
    Name      = "poc-infra-subnet-privada-b"
    Terraform = "true"
  }
}

## Publicas

resource "aws_subnet" "poc-infra-subnet-publica-a" {
  vpc_id            = aws_vpc.poc-infra-vpc.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "us-east-2a"

  tags = {
    Name      = "poc-infra-subnet-publica-a"
    Terraform = "true"
  }
}


resource "aws_subnet" "poc-infra-subnet-publica-b" {
  vpc_id            = aws_vpc.poc-infra-vpc.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "us-east-2b"

  tags = {
    Name      = "poc-infra-subnet-publica-b"
    Terraform = "true"
  }
}
