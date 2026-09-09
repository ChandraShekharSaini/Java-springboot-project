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

output "private_backend_instance_id" {
  value = aws_instance.private_ec2_1a.id
}


output "private_frontend_instance_id" {
  value = aws_instance.private_ec2_1b.id

}

output "private_backend_instance_ip" {
  value = aws_instance.private_ec2_1a.private_ip
}

output "private_frontend_instance_ip" {
  value = aws_instance.private_ec2_1b.private_ip
}

output "frontend_alb_dns_name" {
  value = aws_lb.frontend_alb.dns_name
}


output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}