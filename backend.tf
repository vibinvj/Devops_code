terraform {
  backend "s3" {
    bucket = "statefiletfv"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}