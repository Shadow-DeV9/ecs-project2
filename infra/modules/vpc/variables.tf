variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr" {
  description = "The CIDR block for subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr" {
  description = "The CIDR block for subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_a" {
  description = "The availability zone for subnet A"
  type        = string
  default     = "eu-north-1a"
}

variable "availability_zone_b" {
  description = "The availability zone for subnet B"
  type        = string
  default     = "eu-north-1b"
}
