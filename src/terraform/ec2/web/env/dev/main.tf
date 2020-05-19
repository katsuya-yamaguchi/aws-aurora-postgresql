terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "web01/ec2/web/dev.tfstate"
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

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "tfstate.katsuya-place.com"
    region = "ap-northeast-1"
    key    = "web01/s3/dev.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "tfstate.katsuya-place.com"
    region = "ap-northeast-1"
    key    = "web01/iam/role/dev.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "AMI_IMAGE_ID" {}

module "ec2" {
  source = "../../module/ec2"

  env                      = "dev"
  az_a                     = "ap-northeast-1a"
  az_c                     = "ap-northeast-1c"
  instance_type            = "t2.micro"
  AMI_IMAGE_ID             = var.AMI_IMAGE_ID
  key_pair_name            = "web01"
  subnet_id_private_web_a  = data.terraform_remote_state.network.outputs.subnet_id_private_web_a
  subnet_id_private_web_c  = data.terraform_remote_state.network.outputs.subnet_id_private_web_c
  security_group_web       = data.terraform_remote_state.network.outputs.security_group_web
  web_instance_profile_arn = data.terraform_remote_state.iam.outputs.web_instance_profile_arn
  web_lb_target_group_arn  = module.elb.web_lb_target_group_arn
}

module "elb" {
  source = "../../module/elb"

  env                     = "dev"
  subnet_id_private_web_a = data.terraform_remote_state.network.outputs.subnet_id_private_web_a
  subnet_id_private_web_c = data.terraform_remote_state.network.outputs.subnet_id_private_web_c
  security_group_alb      = data.terraform_remote_state.network.outputs.security_group_alb
  logging_bucket          = data.terraform_remote_state.s3.outputs.s3_bucket_logging
  vpc_id                  = data.terraform_remote_state.network.outputs.vpc_id
}
