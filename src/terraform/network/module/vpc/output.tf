##################################################
# vpc
##################################################
output "vpc_id" {
  value = aws_vpc.main.id
}

##################################################
# internet gateway
##################################################
output "internet_gateway" {
  value = aws_internet_gateway.igw
}

##################################################
# subnet
##################################################
output "subnet_id_public_a" {
  value = aws_subnet.public_a.id
}
output "subnet_id_public_c" {
  value = aws_subnet.public_c.id
}
output "subnet_id_private_db_a" {
  value = aws_subnet.private_db_a.id
}
output "subnet_id_private_db_c" {
  value = aws_subnet.private_db_c.id
}

##################################################
# route table
##################################################
output "route_table_id_public_a" {
  value = aws_route_table.public_a.id
}
output "route_table_id_public_c" {
  value = aws_route_table.public_c.id
}
