output "acm_certificate_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "The ARN of the ACM certificate"
}

output "domain_validation_options" {
  description = "Domain validation options for the ACM certificate"
  value       = aws_acm_certificate.cert.domain_validation_options
}
