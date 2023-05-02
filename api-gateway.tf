resource "aws_api_gateway_rest_api" "integracoes" {
  name        = "cerebrum-integracoes"
  description = "API criada para integrações entre os produtos"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  minimum_compression_size = 0
  binary_media_types = [
    "multipart/form-data"
  ]
}

resource "aws_api_gateway_deployment" "integracoes" {
  rest_api_id = aws_api_gateway_rest_api.integracoes.id
  description = "Deploy em dev"

  #   triggers = {
  #     # redeployment = sha1("a")
  #     redeployment = sha1(jsonencode([for path in fileset("./", "modules/api_gateway/**/*.tf") : filesha1(path)]))
  #   }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_resource.integracoes_dogs,
    aws_api_gateway_method.integracoes_dogs,
    aws_api_gateway_integration.integracoes_dogs_get
  ]
}

resource "aws_api_gateway_stage" "integracoes" {
  deployment_id = aws_api_gateway_deployment.integracoes.id
  rest_api_id   = aws_api_gateway_rest_api.integracoes.id
  stage_name    = "dev"

  variables = {
    loadBalancerCursosSvc = aws_lb.cursos-svc-alb.dns_name
  }

  #   cache_cluster_enabled = true
  #   cache_cluster_size    = 0.5
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



####
# ROTAS
####

resource "aws_api_gateway_resource" "integracoes_dogs" {
  rest_api_id = aws_api_gateway_rest_api.integracoes.id
  parent_id   = aws_api_gateway_rest_api.integracoes.root_resource_id
  path_part   = "dogs"
}


resource "aws_api_gateway_method" "integracoes_dogs" {
  rest_api_id   = aws_api_gateway_rest_api.integracoes.id
  resource_id   = aws_api_gateway_resource.integracoes_dogs.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integracoes_dogs_get" {
  rest_api_id = aws_api_gateway_rest_api.integracoes.id
  resource_id = aws_api_gateway_resource.integracoes_dogs.id
  http_method = "GET"

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://$${stageVariables.loadBalancerCursosSvc}/dogs"
  connection_type         = "INTERNET"
  passthrough_behavior    = "WHEN_NO_MATCH"
}
