module "cerebrum_cursos_svc_ecr" {
  source = "./modules/ecr"

  name_ecr = "cerebrum-cursos-svc"
}


module "cerebrum_cluster" {
  source = "./modules/ecs/cluster"

  name_cluster = "cerebrum"
}


module "cerebrum_cursos_svc_task-definition" {
  source = "./modules/ecs/task-definition"

  family_name_td     = "cursos-svc"
  container_name_td  = "cursos-svc"
  container_image_td = module.cerebrum_cursos_svc_ecr.repository_url
  iam_role_name      = "ecs_task_role_cursos"
  iam_policy_name    = "ecr_access_policy_cursos"

  depends_on = [
    module.cerebrum_cursos_svc_ecr,
  ]
}

module "cerebrum_cursos_svc_service" {
  source = "./modules/ecs/service"

  name                = "service-cursos-svc"
  cluster_id          = module.cerebrum_cluster.id
  task_definition_arn = module.cerebrum_cursos_svc_task-definition.arn

  network_configuration = {
    subnets = [aws_subnet.poc-infra-subnet-privada-a.id, aws_subnet.poc-infra-subnet-privada-b.id]
    security_groups = [
      aws_security_group.cursos_svc_lb_sg.id,
    ]
  }

  load_balancer = {
    target_group_arn = aws_lb_target_group.cursos-svc-lb-tg.arn
    container_name   = module.cerebrum_cursos_svc_task-definition.container_name
    container_port   = 80
  }

  depends_on = [module.cerebrum_cursos_svc_task-definition]
}
