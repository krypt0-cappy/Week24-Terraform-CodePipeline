#---root/backend.tf---

terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "us-west-2"
    profile = "default"
    key     = "Week24-FinalProject/terraform.tfstate"
    bucket  = "week24-finalproject-bucket"
  }
}