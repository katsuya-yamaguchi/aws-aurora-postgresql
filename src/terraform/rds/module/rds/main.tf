variable "env" {}
variable "az_a" {}
variable "subnet_id_private_db_a" {}
variable "subnet_id_private_db_c" {}
variable "security_group_db" {}


resource "aws_iam_role" "default" {
  name               = "rds_monitoring_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.default.name
}


resource "aws_db_instance" "db" {
  allocated_storage           = 20
  allow_major_version_upgrade = false
  apply_immediately           = false
  auto_minor_version_upgrade  = false
  # availability_zone           = var.az_a
  backup_retention_period = 0
  backup_window           = "16:00-16:30"
  # ca_cert_identifier                    = ""
  copy_tags_to_snapshot    = true
  db_subnet_group_name     = aws_db_subnet_group.db.name
  delete_automated_backups = true
  deletion_protection      = false
  # enabled_cloudwatch_logs_exports       = []
  engine              = "MySQL"
  engine_version      = "5.7.28"
  skip_final_snapshot = true
  # final_snapshot_identifier             = ""
  iam_database_authentication_enabled = true
  identifier                          = "main"
  instance_class                      = "db.t2.micro"
  # iops                                = "gp2"
  maintenance_window    = "Sun:02:00-Sun:02:30"
  max_allocated_storage = 0
  monitoring_interval   = 1
  monitoring_role_arn   = aws_iam_role.default.arn
  #multi_az              = true
  multi_az = false
  name     = "sample_app"
  # option_group_name    = "sample_app"
  parameter_group_name = aws_db_parameter_group.db_pg.name
  password             = "sample_app"
  port                 = 3306
  publicly_accessible  = false
  # replicate_source_db  = aws_db_instance.db.identifier
  # storage_encrypted    = false
  # kms_key_id            = aws_kms_key.rds_storage.arn
  username = "admin"
  vpc_security_group_ids = [
    var.security_group_db
  ]
  # performance_insights_enabled = true
  # performance_insights_kms_key_id       = aws_kms_key.rds_performance_insight.id
  # performance_insights_retention_period = 7 

  lifecycle {
    ignore_changes = [password]
  }

  tags = {
    Env = var.env
  }
}

# resource "aws_kms_key" "rds_storage" {
#   description             = "key to encrypt rds storage."
#   key_usage               = "ENCRYPT_DECRYPT"
#   deletion_window_in_days = 7
#   enable_key_rotation     = false
#   tags = {
#     Name = "rds_storage"
#     Env  = var.env
#   }
# }

# resource "aws_kms_key" "rds_performance_insight" {
#   description             = "key to encrypt rds performance insight."
#   key_usage               = "ENCRYPT_DECRYPT"
#   deletion_window_in_days = 7
#   enable_key_rotation     = false
#   tags = {
#     Name = "rds_performance_insight"
#     Env  = var.env
#   }
# }

resource "aws_db_subnet_group" "db" {
  name = "db"
  subnet_ids = [
    var.subnet_id_private_db_a,
    var.subnet_id_private_db_c
  ]

  tags = {
    Env = var.env
  }
}

resource "aws_db_parameter_group" "db_pg" {
  name   = "mysql"
  family = "mysql5.7"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "3"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
}

# resource "aws_db_option_group" "db" {
#   name = "sample_db"
#   engine_name = "MySQL"
#   major_engine_version = ""
#   option {
#     option_name = ""
#     option_settings {
#       name = ""
#       value = ""
#     }
#   }
# }
