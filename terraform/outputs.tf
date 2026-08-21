output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_ec2_1a_public_ip" {
  value = aws_instance.public_ec2_1a.public_ip
}

output "public_ec2_1b_public_ip" {
  value = aws_instance.public_ec2_1b.public_ip
}

output "private_ec2_1a_private_ip" {
  value = aws_instance.private_ec2_1a.private_ip
}

output "private_ec2_1b_private_ip" {
  value = aws_instance.private_ec2_1b.private_ip
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}