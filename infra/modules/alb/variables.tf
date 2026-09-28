variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "subnet_a_id" {
  description = "The ID of subnet A where the ALB will be deployed"
  type        = string
}

variable "subnet_b_id" {
  description = "The ID of subnet B where the ALB will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS"
  type        = string
}
