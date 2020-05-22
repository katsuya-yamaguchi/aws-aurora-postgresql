variable "env" {}
variable "az_a" {}
variable "subnet_id_private_db_a" {}
variable "subnet_id_private_db_c" {}
variable "security_group_db" {}
variable "db_identifier" {
  type    = string
  default = "sample"
}


##################################################
# iam role
##################################################
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

##################################################
# rds cluster
##################################################
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

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier    = var.db_identifier
  copy_tags_to_snapshot = true
  database_name         = "sample_app"
  deletion_protection   = false
  master_password       = "1qaz2wSx"
  master_username       = "postgres"

  # クラスタが削除される際にスナップショットを取得する場合の識別子。指定されない場合、スナップショットは作成されない。
  # final_snapshot_identifier = ""

  skip_final_snapshot = true

  # 自動的に3つのAZでクラスタボリュームは構成される。何も指定しない場合、MultiAZで作成される。
  # availability_zones = []

  # MySQLの場合しか使用できない。
  backtrack_window = "0"

  # 保管期間として1~35日が指定できる。
  backup_retention_period = "1"

  # 自動バックアップとは別。インスタンスのスナップショットを取得するためのウィンドウ。
  # aws_rds_cluster_instanceでも設定できるため、どちらかで設定する。
  preferred_backup_window      = "16:00-17:00"
  preferred_maintenance_window = "sun:15:00-sun:16:00"
  port                         = "5432"
  vpc_security_group_ids = [
    var.security_group_db
  ]

  # スナップショットからDBクラスタを作成したい場合に指定する。今回は新規のため、不要。
  # snapshot_identifier = ""
  # global_cluster_identifier = ""

  # リードレプリカを作成する場合にソースとなるDBクラスタ or DBインスタンスを指定する。
  # レプリカは、aws_rds_cluster_instanceのcountで作成する。そのため、この設定をいつ使用するのか不明。
  # replication_source_identifier = ""

  apply_immediately = false

  # aws_rds_cluster_instanceで指定されたサブネットと同じでないといけない。指定する必要がある？
  db_subnet_group_name = aws_db_subnet_group.db.name

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.sample.name
  kms_key_id                      = aws_kms_key.rds_storage.arn
  storage_encrypted               = true
  iam_roles                       = []
  #iam_database_authentication_enabled = ""
  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "11.6"
  source_region  = "ap-northeast-1"
  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  # serverlessモードでのみ有効。
  # scaling_configuration {}
  # enable_http_endpoint = "" 

  lifecycle {
    ignore_changes = [availability_zones, master_password]
  }
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  # count                = 2
  count                = 1
  identifier           = "${var.db_identifier}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.postgresql.cluster_identifier
  engine               = "aurora-postgresql"
  engine_version       = "11.6"
  instance_class       = "db.t3.medium"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db.name
  apply_immediately    = false
  monitoring_role_arn  = aws_iam_role.default.arn
  monitoring_interval  = "60"

  # プライマリインスタンスで障害が発生した際に、レプリカをマスターに昇格させる際の優先度を指定する。
  # どのレプリカも同じ状態になるはずなので、未指定。
  # promotion_tier               = ""

  # MultiAZのため未指定。
  # availability_zone            = var.az_a

  # preferred_backup_window      = "18:00-19:00"
  # preferred_maintenance_window = "sat:15:00-sat:16:00"

  auto_minor_version_upgrade = true

  # t3.medium >= であれば使用できる。
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds_performance_insight.arn

  copy_tags_to_snapshot = true
  # ca_cert_identifier    = "rds-ca-2019"
}

resource "aws_rds_cluster_parameter_group" "sample" {
  name   = var.db_identifier
  family = "aurora-postgresql11"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements, pg_hint_plan"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "5"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

##################################################
# kms
##################################################
resource "aws_kms_key" "rds_storage" {
  description             = "key to encrypt rds storage."
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  tags = {
    Name = "rds_storage"
    Env  = var.env
  }
}

resource "aws_kms_key" "rds_performance_insight" {
  description             = "key to encrypt rds performance insight."
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  tags = {
    Name = "rds_performance_insight"
    Env  = var.env
  }
}

resource "aws_rds_cluster_parameter_group" "sample" {
  name   = "sample"
  family = "aurora-postgresql11"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_hint_plan"
    apply_method = "pending-reboot"
  }
}
