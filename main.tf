module "cerebrum_cursos_svc_ecr" {
  source = "./modules/ecr"

  name_ecr = "cerebrum-cursos-svc"
}
