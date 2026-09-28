module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"

  vpc_id              = module.vpc.vpc_id
  subnet_a_id         = module.vpc.subnet_a_id
  subnet_b_id         = module.vpc.subnet_b_id
  acm_certificate_arn = module.acm.acm_certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  ecr_uri               = module.ecr.uri
  execution_role_arn    = module.iam.role_arn
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  subnet_a_id           = module.vpc.subnet_a_id
  subnet_b_id           = module.vpc.subnet_b_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

module "acm" {
  source = "./modules/acm"

  aws_route53_record_cert_validation_fqdn = module.route53.aws_route53_record_cert_validation_fqdn
}

module "route53" {
  source = "./modules/route53"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.hosted_zone_id

  domain_validation_options = module.acm.domain_validation_options
}
