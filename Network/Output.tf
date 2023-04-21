# Add output variables
output "public_subnet_id" {
  value = aws_subnet.public[*].id
}

# Add output variables
output "private_subnet_id" {
  value = aws_subnet.private[*].id
}


output "vpc_id" {
  value = aws_vpc.main.id
}