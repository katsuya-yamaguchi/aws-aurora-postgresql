terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket  = "tfstate.katsuya-place.com"
    region  = "ap-northeast-1"
    key     = "aws-aurora-postgresql/network/dev.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../../module/vpc"

  env                            = "dev"
  vpc_cidr_block                 = "100.0.0.0/16"
  subnet_cidr_block_public_a     = "100.0.1.0/24"
  subnet_cidr_block_public_c     = "100.0.2.0/24"
  subnet_cidr_block_private_db_a = "100.0.100.0/24"
  subnet_cidr_block_private_db_c = "100.0.200.0/24"
  az_a                           = "ap-northeast-1a"
  az_c                           = "ap-northeast-1c"
}

module "security_group" {
  source = "../../module/security_group"

  env    = "dev"
  vpc_id = module.vpc.vpc_id
}
