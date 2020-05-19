variable "env" {}

data "aws_iam_policy_document" "logging_bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::logging-${var.env}-katsuya-place-work",
      "arn:aws:s3:::logging-${var.env}-katsuya-place-work/*"
    ]
  }
}

resource "aws_s3_bucket" "logging_katsuya_place_work" {
  bucket        = "logging-${var.env}-katsuya-place-work"
  acl           = "private"
  policy        = data.aws_iam_policy_document.logging_bucket_policy.json
  force_destroy = false
  # website = 
  # cors_rule = 

  versioning {
    enabled    = false
    mfa_delete = false
  }

  # logging =
  lifecycle_rule {
    id      = "logging"
    enabled = true
    expiration {
      days = "7"
    }
    #transition {
    #  days          = "30"
    #  storage_class = "STANDARD_IA"
    #}
    noncurrent_version_expiration {
      days = "3"
    }
    #noncurrent_version_transition {
    #  days          = "3"
    #  storage_class = "STANDARD_IA"
    #}
  }

  acceleration_status = "Suspended"
  region              = "ap-northeast-1"
  request_payer       = "BucketOwner"
  # replication_configuration {}

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # object_lock_configuration {
  #   object_lock_enabled = false
  #   rule {
  #     default_retention {
  #       mode  = "GOVERNANCE"
  #       years = "1"
  #     }
  #   }
  # }

  tags = {
    Env = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "logging_katsuya_place_work" {
  bucket                  = aws_s3_bucket.logging_katsuya_place_work.bucket
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "assets_bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::assets-${var.env}-katsuya-place-work",
      "arn:aws:s3:::assets-${var.env}-katsuya-place-work/*"
    ]
  }
}

resource "aws_s3_bucket" "assets_katsuya_place_work" {
  bucket        = "assets-${var.env}-katsuya-place-work"
  acl           = "private"
  policy        = data.aws_iam_policy_document.assets_bucket_policy.json
  force_destroy = false
  # website = 
  # cors_rule = 

  versioning {
    enabled    = true
    mfa_delete = false
  }

  # logging =
  # lifecycle_rule {
  #   id      = "assets"
  #   enabled = true
  #   expiration {
  #     days = "7"
  #   }
  #   #transition {
  #   #  days          = "30"
  #   #  storage_class = "STANDARD_IA"
  #   #}
  #   noncurrent_version_expiration {
  #     days = "3"
  #   }
  #   #noncurrent_version_transition {
  #   #  days          = "3"
  #   #  storage_class = "STANDARD_IA"
  #   #}
  # }

  acceleration_status = "Suspended"
  region              = "ap-northeast-1"
  request_payer       = "BucketOwner"
  # replication_configuration {}

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # object_lock_configuration {
  #   object_lock_enabled = false
  #   rule {
  #     default_retention {
  #       mode  = "GOVERNANCE"
  #       years = "1"
  #     }
  #   }
  # }

  tags = {
    Env = var.env
  }
}