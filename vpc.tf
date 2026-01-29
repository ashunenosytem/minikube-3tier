resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.primary_vpc.id
}
resource "aws_subnet" "public_mumbai" {
  vpc_id                  = aws_vpc.primary_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block              = "10.10.10.0/24"
  map_public_ip_on_launch = true
   tags = {
    Name = "public-mumbai"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_mumbai.id
  route_table_id = aws_route_table.public_rt.id
}
