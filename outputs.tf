output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_1a_id" {
  description = "ID of public subnet 1a"
  value       = aws_subnet.public_1a.id
}

output "public_subnet_1b_id" {
  description = "ID of public subnet 1b"
  value       = aws_subnet.public_1b.id
}

output "private_subnet_1a_id" {
  description = "ID of private subnet 1a"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1b_id" {
  description = "ID of private subnet 1b"
  value       = aws_subnet.private_1b.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_1a_id" {
  description = "ID of NAT Gateway in 1a"
  value       = aws_nat_gateway.nat_1a.id
}

output "nat_gateway_1b_id" {
  description = "ID of NAT Gateway in 1b"
  value       = aws_nat_gateway.nat_1b.id
}

output "nat_gateway_1a_public_ip" {
  description = "Public IP of NAT Gateway in 1a"
  value       = aws_eip.nat_1a.public_ip
}

output "nat_gateway_1b_public_ip" {
  description = "Public IP of NAT Gateway in 1b"
  value       = aws_eip.nat_1b.public_ip
}