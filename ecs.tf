resource "aws_ecs_cluster" "cerebrum_integracoes_cluster" {
  name = "cerebrum_integracoes_cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name      = "cerebrum_integracoes_cluster"
    Terraform = "true"
    Stack     = "Fargate"
  }
}

resource "aws_ecs_task_definition" "cursos_svc_td" {
  family                   = "cursos"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    {
      name      = "cursos-svc-td"
      image     = "${aws_ecr_repository.cursos-svc-ecr.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = aws_iam_role.ecs_task_role.arn

  depends_on = [
    aws_ecr_repository.cursos-svc-ecr,
  ]
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name = "ecr_access_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  policy_arn = aws_iam_policy.ecr_access_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_ecs_service" "cerebrum_integracoes_service" {
  name = "cerebrum_integracoes_service"

  cluster         = aws_ecs_cluster.cerebrum_integracoes_cluster.id
  task_definition = aws_ecs_task_definition.cursos_svc_td.arn

  desired_count = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.poc-infra-subnet-privada-a.id, aws_subnet.poc-infra-subnet-privada-b.id]

    security_groups = [
      aws_security_group.cursos_svc_lb_sg.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cursos-svc-lb-tg.arn
    container_name   = "cursos-svc-td"
    container_port   = 80
  }

  tags = {
    Name      = "cerebrum_integracoes_service"
    Terraform = "true"
    Stack     = "Fargate"
  }
}
