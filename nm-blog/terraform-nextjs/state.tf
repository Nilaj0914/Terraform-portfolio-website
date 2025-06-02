terraform {
  backend "s3" {
    bucket = "nilaj-terraform-website"
    key = "global/s3/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}