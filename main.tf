# 1. VPC NETWORKING

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "web-vpc"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "web-igw"
    Environment = var.environment
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "web-subnet"
    Environment = var.environment
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "web-rt"
    Environment = var.environment
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# 2. SECURITY INFRASTRUCTURE

# Create Security Group
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name        = "web-sg"
    Environment = var.environment
  }
}

# 3. COMPUTE INFRASTRUCTURE

# User Data Script

data "template_file" "user_data" {
  template = <<-EOF
    #!/bin/bash
    # Update packages
    yum update -y

    # Install Apache
    yum install -y httpd

    # Start web server
    systemctl start httpd
    systemctl enable httpd

    # Create custom webpage
    echo "<html>
    <head><title>Automated Cloud Infrastructure</title></head>
    <body>
      <h1>Welcome to Automated Cloud Infrastructure via IaC!</h1>
      <p>Deployed using Terraform on AWS</p>
      <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
      <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
    </body>
    </html>" > /var/www/html/index.html

    # Set permissions
    chown -R apache:apache /var/www/html/
    chmod -R 755 /var/www/html/
  EOF
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name        = "web-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_subnet.public,
    aws_security_group.web,
    aws_internet_gateway.main
  ]
}

# Create Elastic IP
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name        = "web-eip"
    Environment = var.environment
  }
}


