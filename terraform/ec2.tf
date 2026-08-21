resource "aws_instance" "public_ec2_1a" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_admin_profile.name

  tags = {
    Name = "public-ec2-1a"
  }
}

resource "aws_instance" "private_ec2_1a" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_admin_profile.name

  tags = {
    Name = "private-ec2-1a"
  }
}

resource "aws_instance" "public_ec2_1b" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name = var.key_name

iam_instance_profile = aws_iam_instance_profile.ec2_admin_profile.name
  tags = {
    Name = "public-ec2-1b"
  }
}

resource "aws_instance" "private_ec2_1b" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_admin_profile.name

  tags = {
    Name = "private-ec2-1b"
  }
}