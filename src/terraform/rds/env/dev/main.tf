terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "web01/rds/dev.tfstate"
    encrypt = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tfstate.katsuya-place.com"
    region = "ap-northeast-1"
    key    = "web01/network/dev.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "rds" {
  source = "../../module/rds"

  env                    = "dev"
  az_a                   = "ap-northeast-1a"
  subnet_id_private_db_a = data.terraform_remote_state.network.outputs.subnet_id_private_db_a
  subnet_id_private_db_c = data.terraform_remote_state.network.outputs.subnet_id_private_db_c
  security_group_db      = data.terraform_remote_state.network.outputs.security_group_db
}