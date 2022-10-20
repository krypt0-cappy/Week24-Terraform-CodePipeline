#---networking/outputs.tf---

output "public_subnet" {
  value = aws_subnet.krypt0_24_public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.krypt0_24_vpc.id
}

output "public_sg" {
  value = aws_security_group.web_sg.id
}