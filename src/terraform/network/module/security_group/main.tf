variable "env" {}
variable "vpc_id" {}

##################################################
# security group (web)
##################################################
resource "aws_security_group" "web" {
  name                   = "web"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = false

  tags = {
    Name = "web"
    Env  = var.env
  }
}

resource "aws_security_group_rule" "web_permit_http_from_internet" {
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit http from internet."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
}

resource "aws_security_group_rule" "web_permit_ssh_from_internet" {
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit ssh from internet."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
}

resource "aws_security_group_rule" "web_permit_egress" {
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit to egress."
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
}

##################################################
# security group (db)
##################################################
resource "aws_security_group" "db" {
  name                   = "db"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = false

  tags = {
    Name = "db"
    Env  = var.env
  }
}

resource "aws_security_group_rule" "db_permit_from_web" {
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
  description              = "permit from web."
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "5432"
  to_port                  = "5432"
}
