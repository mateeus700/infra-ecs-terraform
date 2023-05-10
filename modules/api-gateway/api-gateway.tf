resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description

  endpoint_configuration {
    types = var.types
  }

  minimum_compression_size = var.minimum_compression_size
  binary_media_types       = var.binary_media_types
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  description = var.deployment_description

  #   triggers = {
  #     # redeployment = sha1("a")
  #     redeployment = sha1(jsonencode([for path in fileset("./", "modules/api_gateway/**/*.tf") : filesha1(path)]))
  #   }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.cerebrum_cursos_svc_api_gateway]
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  variables = var.load_balancer_variables

  #   cache_cluster_enabled = var.cache_cluster_enabled
  #   cache_cluster_size    = var.cache_cluster_size
}

# resource "aws_api_gateway_method_settings" "all" {
#   rest_api_id = aws_api_gateway_rest_api.frontends.id
#   stage_name  = aws_api_gateway_stage.frontends.stage_name
#   method_path = "*/*"

#   settings {
#     caching_enabled      = true
#     cache_ttl_in_seconds = 30
#   }

#   depends_on = [
#     aws_api_gateway_deployment.frontends
#   ]
# }


module "cerebrum_cursos_svc_api_gateway" {
  source = "./cursos-svc"

  rest_api_id      = aws_api_gateway_rest_api.this.id
  root_resource_id = aws_api_gateway_rest_api.this.root_resource_id

  depends_on = [aws_api_gateway_rest_api.this]
}
