module "cerebrum_cursos_svc_ecr" {
  source = "./modules/ecr"

  name_ecr = "cerebrum-cursos-svc"
}


module "cerebrum_cluster" {
  source = "./modules/ecs/cluster"

  name = "cerebrum"
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

  name                 = "service-cursos-svc"
  cluster_id           = module.cerebrum_cluster.id
  task_definition_arn  = module.cerebrum_cursos_svc_task-definition.arn
  force_new_deployment = true

  network_configuration = {
    subnets = [aws_subnet.poc-infra-subnet-privada-a.id, aws_subnet.poc-infra-subnet-privada-b.id]
    security_groups = [
      module.security_group_http.id,
    ]
  }

  load_balancer = {
    target_group_arn = module.cerebrum_cursos_svc_target_group.arn
    container_name   = module.cerebrum_cursos_svc_task-definition.container_name
    container_port   = 80
  }

  depends_on = [module.cerebrum_cursos_svc_task-definition]
}

module "security_group_http" {
  source = "./modules/ec2/security-group"

  name        = "http_https"
  description = "Permitindo trafego http e https"
  vpc_id      = aws_vpc.poc-infra-vpc.id

  ingress_rules = [
    {
      description = "HTTPS Allowed"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP Allowed"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}

module "cerebrum_cursos_svc_target_group" {
  source = "./modules/ec2/target-group"

  name        = "cerebrum-cursos-svc-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.poc-infra-vpc.id

  health_check = {
    path = "/"
    port = 80
  }
}


module "cerebrum_cursos_svc_load_balance" {
  source = "./modules/ec2/load-balance"

  name               = "cerebrum-cursos-svc-load-balance"
  internal           = false
  load_balancer_type = "application"

  security_groups = [module.security_group_http.id]
  subnets         = [aws_subnet.poc-infra-subnet-publica-a.id, aws_subnet.poc-infra-subnet-publica-b.id]
}


module "cerebrum_cursos_svc_target_group_listener" {
  source = "./modules/ec2/target-group-listener"

  load_balancer_arn = module.cerebrum_cursos_svc_load_balance.arn
  port              = 80
  protocol          = "HTTP"

  default_action = {
    type             = "forward"
    target_group_arn = module.cerebrum_cursos_svc_target_group.arn
  }
}


module "cerebrum_integracoes_api_gateway" {
  source = "./modules/api-gateway/api-gateway-config"

  name                     = "cerebrum-integracoes"
  description              = "API criada para integrações entre os produtos"
  types                    = ["REGIONAL"]
  binary_media_types       = ["multipart/form-data"]
  minimum_compression_size = 0
  deployment_description   = "Deploy em dev"
  stage_name               = "dev"

  load_balancer_variables = {
    loadBalancerCursosSvc = module.cerebrum_cursos_svc_load_balance.dns_name
  }
}

module "cerebrum_cursos_svc_api_gateway" {
  source = "./modules/micro-servicos/cursos-svc/api-gateway"

  rest_api_id      = module.cerebrum_integracoes_api_gateway.api_gateway_id
  root_resource_id = module.cerebrum_integracoes_api_gateway.api_gateway_root_resource_id

  depends_on = [module.cerebrum_integracoes_api_gateway]
}
