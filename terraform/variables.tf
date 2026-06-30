variable "project_name" {
  description = "Project name used for tagging and naming AWS resources."
  type        = string
  default     = "zuri-market"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the single-node k3s cluster."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 20
}

variable "public_key_path" {
  description = "Local path to the public SSH key Terraform will upload to AWS."
  type        = string
}

variable "private_key_path" {
  description = "Local path to the private SSH key used for SSH output."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH and access k3s API. Use your public IP with /32."
  type        = string
}

variable "allowed_app_cidr" {
  description = "CIDR allowed to access the public app NodePort."
  type        = string
  default     = "0.0.0.0/0"
}
