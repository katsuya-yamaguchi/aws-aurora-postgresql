variable "env" {}
variable "account_id" {}
variable "rds_db_user_name" {}


resource "aws_iam_role" "web" {
  name               = "ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  tags = {
    Env = var.env
  }
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_access_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "rds-db:connect",
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:rds-db:ap-northeast-1:${var.account_id}:dbuser:*/${var.rds_db_user_name}",
      "arn:aws:s3:::assets-${var.env}-katsuya-place-work",
      "arn:aws:s3:::assets-${var.env}-katsuya-place-work/*"
    ]
  }
}

resource "aws_iam_policy" "rds_access_policy" {
  name   = "rds_access_policy"
  policy = data.aws_iam_policy_document.rds_access_policy.json
}

resource "aws_iam_role_policy_attachment" "web_rds_access_policy" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.rds_access_policy.arn
}

resource "aws_iam_instance_profile" "web" {
  name = "web"
  role = aws_iam_role.web.name
}
