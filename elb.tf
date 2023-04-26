resource "aws_lb" "cursos-svc-alb" {
  name               = "poc-infra-elb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.cursos_svc_lb_sg.id]
  subnets         = [aws_subnet.poc-infra-subnet-publica-a.id, aws_subnet.poc-infra-subnet-publica-b.id]

  tags = {
    Environment = "cursos-svc-alb"
    Terraform   = "true"
  }
}


resource "aws_security_group" "cursos_svc_lb_sg" {
  name        = "cursos_svc_sg"
  description = "Permitindo trafego http e https"
  vpc_id      = aws_vpc.poc-infra-vpc.id

  ingress {
    description = "HTTPS Allowed"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Allowed"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "cursos-svc-lb-sg"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "cursos-svc-lb-tg" {
  name        = "cursos-svc-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.poc-infra-vpc.id

  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_lb_listener" "cursos-svc-lb-tg-listener" {
  load_balancer_arn = aws_lb.cursos-svc-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cursos-svc-lb-tg.arn
  }
}
