variable "domain_validation_options" {
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}

variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}
