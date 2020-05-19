terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "web01/iam/role/dev.tfstate"
    encrypt = true
  }
}

data "aws_caller_identity" "self" {}

provider "aws" {
  region = "ap-northeast-1"
}

module "role" {
  source = "../../module/role"

  env              = "dev"
  account_id       = data.aws_caller_identity.self.account_id
  rds_db_user_name = "viewer"
}
