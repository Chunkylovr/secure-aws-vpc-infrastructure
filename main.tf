terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Subnet 1 (AZ 1a)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-1a"
  }
}

# Public Subnet 2 (AZ 1b)
resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-1b"
  }
}

# Private Subnet 1 (AZ 1a)
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment}-private-1a"
  }
}

# Private Subnet 2 (AZ 1b)
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.environment}-private-1b"
  }
}

# Elastic IP for NAT Gateway 1
resource "aws_eip" "nat_1a" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.environment}-eip-nat-1a"
  }
}

# Elastic IP for NAT Gateway 2
resource "aws_eip" "nat_1b" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.environment}-eip-nat-1b"
  }
}

# NAT Gateway 1 (in public subnet 1a)
reso