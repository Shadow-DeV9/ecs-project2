variable "ecr_uri" {
  description = "The URI of the ECR repository"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ECS cluster will be deployed"
  type        = string
}

variable "alb_security_group_id" {
  description = "The security group ID of the ALB"
  type        = string
}

variable "subnet_a_id" {
  description = "The ID of the first subnet for the ECS service"
  type        = string
}

variable "subnet_b_id" {
  description = "The ID of the second subnet for the ECS service"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the ALB target group"
  type        = string
}
