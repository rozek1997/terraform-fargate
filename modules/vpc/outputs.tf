output "vpc" {
  value = aws_vpc.main
}

output "vpc_public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "vpc_private_subnets_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "sec_group" {
  value = aws_security_group.nat_sec_group
}
