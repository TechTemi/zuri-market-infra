resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "default_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "k3s" {
  name        = "${local.name_prefix}-k3s-sg"
  description = "Security group for Zuri Market single-node k3s cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Kubernetes API from trusted IP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Zuri frontend NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_app_cidr]
  }

  # Risk accepted for capstone single-node k3s host.
  # Justification: outbound HTTPS is required for DockerHub image pulls, AWS Secrets Manager, AWS APIs, and package repositories.
  # Compensating controls: egress is limited to TCP 443, inbound SSH/API is restricted, and IAM is scoped to Zuri Market secrets.
  egress {
    description = "Allow outbound HTTPS for DockerHub, AWS APIs, package downloads, and Secrets Manager"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #trivy:ignore:AVD-AWS-0104 trivy:ignore:AWS-0104
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Risk accepted for capstone single-node k3s bootstrap.
  # Justification: outbound HTTP is required during bootstrap for installation scripts and package repository redirects.
  # Compensating controls: limited to TCP 80 only; production replacement would use approved package mirrors or controlled egress.
  egress {
    description = "Allow outbound HTTP for package repository redirects and bootstrap downloads"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #trivy:ignore:AVD-AWS-0104 trivy:ignore:AWS-0104
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Risk accepted for capstone single-node k3s host.
  # Justification: outbound DNS is required so the node can resolve DockerHub, AWS, and package repository endpoints.
  # Compensating controls: limited to UDP 53 only; production replacement would use VPC DNS controls and private endpoints where possible.
  egress {
    description = "Allow outbound DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    #trivy:ignore:AVD-AWS-0104 trivy:ignore:AWS-0104
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k3s-sg"
  })
}