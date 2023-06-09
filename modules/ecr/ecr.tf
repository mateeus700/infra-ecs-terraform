resource "aws_ecr_repository" "this" {
  name = var.name_ecr

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "Name" = var.name_ecr
  }
}
