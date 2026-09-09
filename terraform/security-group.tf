resource "aws_security_group" "public_sg" {
  name        = "public-ec2-sg"
  description = "Security group for public EC2"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-ec2-sg"
  }
}


resource "aws_security_group" "private_sg" {
  name        = "private-ec2-sg"
  description = "Security group for private EC2"
  vpc_id      = aws_vpc.main_vpc.id

  # SSH from Public EC2
  ingress {
    description     = "SSH from public EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # HTTP
  ingress {
    description     = "HTTP from Public EC2"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # HTTPS
  ingress {
    description     = "HTTPS from Public EC2"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Streamlit
  ingress {
    description     = "Streamlit from Public EC2"
    from_port       = 8501
    to_port         = 8501
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }


    # Streamlit
  ingress {
    description     = "Streamlit from Public EC2"
    from_port       = 8084
    to_port         = 8084
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }


  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}




resource "aws_security_group" "frontend_alb_sg" {
  name        = "frontend-alb-sg"
  description = "Security group for frontend ALB"
  vpc_id      = aws_vpc.main_vpc.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-alb-sg"
  }
}

