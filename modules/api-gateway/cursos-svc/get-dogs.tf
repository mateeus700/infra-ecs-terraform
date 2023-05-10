resource "aws_api_gateway_method" "integracoes_dogs" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.integracoes_dogs.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integracoes_dogs_get" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.integracoes_dogs.id
  http_method = "GET"

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://$${stageVariables.loadBalancerCursosSvc}/dogs"
  connection_type         = "INTERNET"
  passthrough_behavior    = "WHEN_NO_MATCH"

  depends_on = [aws_api_gateway_method.integracoes_dogs]
}
