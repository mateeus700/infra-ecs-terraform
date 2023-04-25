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
