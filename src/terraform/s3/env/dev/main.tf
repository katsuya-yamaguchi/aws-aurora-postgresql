terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "web01/s3/dev.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "s3" {
  source = "../../module/s3"

  env = "dev"
}
