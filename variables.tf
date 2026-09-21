variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023 (ap-southeast-1)"
  type        = string
  default     = "ami-03271cad8bd3a558e"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}