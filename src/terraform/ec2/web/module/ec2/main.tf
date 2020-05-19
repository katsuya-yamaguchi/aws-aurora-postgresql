variable "env" {}
variable "az_a" {}
variable "az_c" {}
variable "instance_type" {}
variable "key_pair_name" {}
variable "subnet_id_private_web_a" {}
variable "subnet_id_private_web_c" {}
variable "security_group_web" {}
variable "web_instance_profile_arn" {}
variable "AMI_IMAGE_ID" {}
variable "web_lb_target_group_arn" {}

resource "aws_launch_template" "web" {
  name                                 = "web"
  description                          = ""
  disable_api_termination              = false
  image_id                             = var.AMI_IMAGE_ID
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile {
    arn = var.web_instance_profile_arn
  }
  instance_type = var.instance_type
  user_data     = filebase64("${path.module}/userdata.sh")
  key_name      = "web01"
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = [var.security_group_web]

  tags = {
    Name = "web"
    Env  = var.env
  }
}


resource "aws_autoscaling_group" "web" {
  name             = "web"
  max_size         = 3
  min_size         = 1
  default_cooldown = 300
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  # load_balancers = 
  vpc_zone_identifier = [
    var.subnet_id_private_web_a,
    var.subnet_id_private_web_c
  ]
  termination_policies = ["Default"]
  # placement_group = 
  metrics_granularity = "1Minute"
  # enabled_metrics           = ""
  wait_for_capacity_timeout = "10m"
  protect_from_scale_in     = false
  # service_linked_role_arn = 
  target_group_arns = [
    var.web_lb_target_group_arn
  ]
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                      = "scale_out_policy"
  autoscaling_group_name    = aws_autoscaling_group.web.name
  adjustment_type           = "ChangeInCapacity"
  estimated_instance_warmup = 300
  policy_type               = "StepScaling"

  # 80~90%
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 20
    metric_interval_upper_bound = 30
  }

  # 90%~
  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 30
  }
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                      = "scale_in_policy"
  autoscaling_group_name    = aws_autoscaling_group.web.name
  adjustment_type           = "ChangeInCapacity"
  estimated_instance_warmup = 300
  policy_type               = "StepScaling"

  # ~30%
  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_upper_bound = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 60
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]
}
