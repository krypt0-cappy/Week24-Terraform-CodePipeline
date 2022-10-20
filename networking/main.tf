#---networking/main.tf---

data "aws_availability_zones" "available" {}

resource "random_pet" "random" {}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names
}

# Create VPC
resource "aws_vpc" "krypt0_24_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "krypt0_24_vpc_${random_pet.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Public Subnets
resource "aws_subnet" "krypt0_24_public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.krypt0_24_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "krypt0_24_public_subnet_${count.index + 1}"
  }
}

# Create Public Route Table Association
resource "aws_route_table_association" "krypt0_public_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.krypt0_24_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.krypt0_24_public_rt.id
}

# Create Public Route Table
resource "aws_route_table" "krypt0_24_public_rt" {
  vpc_id = aws_vpc.krypt0_24_vpc.id

  tags = {
    Name = "krypt0_24_public_rt"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "krypt0_24_internet_gateway" {
  vpc_id = aws_vpc.krypt0_24_vpc.id

  tags = {
    Name = "krypt0_24_internet_gateway"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Elastic IP
resource "aws_eip" "krypt0_24_eip" {}

# Create NAT Gateway
resource "aws_nat_gateway" "krypt0_24_nat_gateway" {
  allocation_id = aws_eip.krypt0_24_eip.id
  subnet_id     = aws_subnet.krypt0_24_public_subnet[1].id
}

# Create Default Public Route
resource "aws_route" "krypt0_24_default_public_route" {
  route_table_id         = aws_route_table.krypt0_24_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.krypt0_24_internet_gateway.id
}

resource "aws_security_group" "web_sg" {
  name        = "WebServer Security Group --- HTTP/HTTPS Traffic"
  description = "HTTP/HTTPS Traffic"
  vpc_id      = aws_vpc.krypt0_24_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
