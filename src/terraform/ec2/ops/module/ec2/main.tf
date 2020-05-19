variable "env" {}
variable "instance_type" {}
variable "az_a" {}
variable "az_c" {}
variable "key_pair_name" {}
variable "subnet_id_public_a" {}
variable "subnet_id_public_c" {}
variable "security_group_bastion" {}

resource "aws_instance" "bastion_az_a" {
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
  vpc_security_group_ids      = [var.security_group_bastion]
  subnet_id                   = var.subnet_id_public_a
  associate_public_ip_address = false
  source_dest_check           = true
  # user_data = file("${path.module}/userdata.sh")
  ipv6_address_count = 0
  # ipv6_addresses = 
  hibernation = false
  volume_tags = {
    Name = "bastion_az_a"
    Env  = var.env
  }
  tags = {
    Name = "bastion_az_a"
    Env  = var.env
  }
}

# resource "aws_instance" "bastion_az_c" {
#   ami               = "ami-0c6f9336767cd9243"
#   instance_type     = var.instance_type
#   availability_zone = var.az_c
#   # placement_group = 
#   # tenancy = 
#   # host_id = 
#   # cpu_core_count = 
#   # cpu_threads_per_core = 
#   disable_api_termination              = false
#   instance_initiated_shutdown_behavior = "stop"
#   key_name                             = var.key_pair_name
#   # get_password_data = 
#   monitoring                  = false
#   vpc_security_group_ids      = [var.security_group_bastion]
#   subnet_id                   = var.subnet_id_public_c
#   associate_public_ip_address = false
#   source_dest_check           = true
#   # user_data = file("userdata.sh")
#   ipv6_address_count = 0
#   # ipv6_addresses = 
#   hibernation = false
#   volume_tags = {
#     Name = "bastion_az_c"
#     Env  = var.env
#   }
#   tags = {
#     Name = "bastion_az_c"
#     Env  = var.env
#   }
# }

resource "aws_eip" "bastion_az_a" {
  instance = aws_instance.bastion_az_a.id
  vpc      = true
}