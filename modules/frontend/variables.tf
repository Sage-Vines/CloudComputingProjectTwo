#front end variables live here
# terraform root passes absolute paths/ports into these so nginx knows what to serve & where
variable "frontend_image_name" {
  description = "Frontend image name"
  type = string
}

variable "frontend_container_name" {
  description = "Frontend container name"
  type = string
}

variable "frontend_host_port" {
  description = "Host port exposed for HTTP traffic"
  type = number
}

variable "shared_network_name" {
  description = "Network to attach frontend container to"
  type = string
}

variable "nginx_config_path" {
  description = "Host path to nginx config file"
  type = string
}

variable "static_site_path" {
  description = "Directory containing static frontend assets"
  type = string
}
