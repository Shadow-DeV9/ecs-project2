resource "aws_acm_certificate" "cert" {
  domain_name       = "tm.shoshin.org.uk"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = var.aws_route53_record_cert_validation_fqdn
}
