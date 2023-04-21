# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
required_providers {
  aws = {
  source = "hashicorp/aws"
  version = ">= 3.27"
 }
}

  required_version = ">=0.14"
} 
provider "aws" {
  profile = "default"
  region = "us-east-1"
}



# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"

}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-public-subnet"
    }
  )
}


resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  cidr_block = "10.1.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.1.${count.index + 5}.0/24"
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-${count.index + 1}"
  }
}

  

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-igw"
    }
  )
}




# Create public route table and association
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public" {
  count = 4
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}



