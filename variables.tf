variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name for resource naming"
  type        = string
  default     = "dev"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "your_ip" {
  description = "Your public IP address for SSH access (get it from 'curl ifconfig.me')"
  type        = string
  default     = "0.0.0.0/32"
}