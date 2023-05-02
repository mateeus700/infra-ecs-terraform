resource "aws_ecs_cluster" "this" {
  name = var.name_cluster

  # Conferir isso \/
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = var.name_cluster
  }
}
