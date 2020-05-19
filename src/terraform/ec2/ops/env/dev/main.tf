terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "web01/ec2/ops/dev.tfstate"
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

module "ec2" {
  source = "../../module/ec2"

  env                    = "dev"
  az_a                   = "ap-northeast-1a"
  az_c                   = "ap-northeast-1c"
  instance_type          = "t2.micro"
  key_pair_name          = "bastion"
  subnet_id_public_a     = data.terraform_remote_state.network.outputs.subnet_id_public_a
  subnet_id_public_c     = data.terraform_remote_state.network.outputs.subnet_id_public_c
  security_group_bastion = data.terraform_remote_state.network.outputs.security_group_bastion
}
