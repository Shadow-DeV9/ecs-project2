resource "aws_s3_bucket" "project_s3_bucket" {
  bucket = "bankai-tensa-zangetsu19"

  tags = {
    Name        = "terraform-state"
    Environment = "Dev"
  }
}
