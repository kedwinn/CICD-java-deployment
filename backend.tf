terraform {
    backend "s3" {
    bucket = "backend75"
    key    = "dev/terraform.tfstate"
    region = "eu-west-2"
  }
}


