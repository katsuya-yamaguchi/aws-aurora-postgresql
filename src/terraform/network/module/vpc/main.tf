variable "env" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block_public_a" {}
variable "subnet_cidr_block_public_c" {}
variable "subnet_cidr_block_private_db_a" {}
variable "subnet_cidr_block_private_db_c" {}
variable "az_a" {}
variable "az_c" {}

##################################################
# vpc
##################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Env = "${var.env}"
  }
}

##################################################
# Internet gateway
##################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
    Env  = var.env
  }
}

##################################################
# public subnet
##################################################
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_public_a
  availability_zone = var.az_a

  tags = {
    Name = "public_a"
    Env  = var.env
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_public_c
  availability_zone = var.az_c

  tags = {
    Name = "public_c"
    Env  = var.env
  }
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public_a"
    Env  = var.env
  }
}

resource "aws_route_table" "public_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public_c"
    Env  = var.env
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_c.id
}

resource "aws_route" "public_a_to_igw" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_c_to_igw" {
  route_table_id         = aws_route_table.public_c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

##################################################
# private_db subnet
##################################################
resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_private_db_a
  availability_zone = var.az_a

  tags = {
    Name = "private_db_a"
    Env  = var.env
  }
}

resource "aws_subnet" "private_db_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_private_db_c
  availability_zone = var.az_c

  tags = {
    Name = "private_db_c"
    Env  = var.env
  }
}

##################################################
# vpc endpoint
##################################################
# resource "aws_vpc_endpoint" "s3" {
#   vpc_endpoint_type = "Gateway"
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.ap-northeast-1.s3"
#   policy            = data.aws_iam_policy_document.vpc_endpoint_s3_policy.json
# }

# data "aws_iam_policy_document" "vpc_endpoint_s3_policy" {
#   statement {
#     sid    = ""
#     effect = "Allow"
#     principals {
#       type = "*"
#       identifiers = [
#         "*"
#       ]
#     }
#     actions = [
#       "s3:DeleteObject*",
#       "s3:GetObject*",
#       "s3:ListBucket",
#       "s3:PutObject"
#     ]
#     resources = [
#       "arn:aws:s3:::assets-${var.env}-katsuya-place-work",
#       "arn:aws:s3:::assets-${var.env}-katsuya-place-work/*"
#     ]
#   }
# }