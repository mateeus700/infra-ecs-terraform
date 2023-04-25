resource "aws_ecr_repository" "cursos-svc-ecr" {
  name = "cursos-svc"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "Terraform" = "True"
    "Name"      = "cursos-svc-ecr"
  }
}