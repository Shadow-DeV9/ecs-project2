output "alb_security_group_id" {
  value       = aws_security_group.ecs_alb_sg.id
  description = "The ID of the security group associated with the ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.master.arn
  description = "The ARN of the target group"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the ALB"
}

output "hosted_zone_id" {
  value       = aws_lb.main.zone_id
  description = "The hosted zone ID of the ALB"
}
