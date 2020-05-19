variable "env" {}
variable "instance_type" {}
variable "az_a" {}
variable "az_c" {}
variable "key_pair_name" {}
variable "subnet_id_public_a" {}
variable "subnet_id_public_c" {}
variable "security_group_web" {}

resource "aws_instance" "web_a" {
  ami               = "ami-0c6f9336767cd9243"
  instance_type     = var.instance_type
  availability_zone = var.az_a
  # placement_group = 
  # tenancy = 
  # host_id = 
  # cpu_core_count = 
  # cpu_threads_per_core = 
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = var.key_pair_name
  # get_password_data = 
  monitoring                  = false
  vpc_security_group_ids      = [var.security_group_web]
  subnet_id                   = var.subnet_id_public_a
  associate_public_ip_address = false
  source_dest_check           = true
  # user_data = file("${path.module}/userdata.sh")
  ipv6_address_count = 0
  # ipv6_addresses = 
  hibernation = false
  volume_tags = {
    Name = "web_a"
    Env  = var.env
  }
  tags = {
    Name = "web_a"
    Env  = var.env
  }
}

resource "aws_eip" "web_a" {
  instance = aws_instance.web_a.id
  vpc      = true
}