variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "types" {
  type = list(string)
}

variable "binary_media_types" {
  type = list(string)
}

variable "minimum_compression_size" {
  type = number
}

variable "deployment_description" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "load_balancer_variables" {
  type = map(string)
}

