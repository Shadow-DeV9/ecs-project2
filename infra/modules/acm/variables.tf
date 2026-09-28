variable "aws_route53_record_cert_validation_fqdn" {
  description = "The FQDNs of the Route 53 records for ACM certificate validation"
  type        = list(string)
}
