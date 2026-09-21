terraform {
  backend "s3" {
    bucket         = "year4sem2-tf-state-2026"
    key            = "web-app/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}