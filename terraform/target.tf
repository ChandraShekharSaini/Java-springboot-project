resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 8501
  protocol = "HTTP"
  vpc_id   =  aws_vpc.main_vpc.id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "8501"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "frontend-tg"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.private_ec2_1b.id
  port             = 8501
}