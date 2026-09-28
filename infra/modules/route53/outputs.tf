output "aws_route53_record_cert_validation_fqdn" {
  value = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  description = "The FQDNs of the Route 53 records for ACM certificate validation"
}
