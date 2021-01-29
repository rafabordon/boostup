data "terraform_remote_state" "vpc" {
  workspace = var.environment
  backend   = "s3"

  config = {
    bucket = "tf-states-boostup"
    key    = "v0.12/webserver/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

