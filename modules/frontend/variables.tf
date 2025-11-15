# front end knobs live here
# terraform root passes absolute paths/ports into these so nginx knows what to serve & where
variable "image_name" {
  description = "Frontend image name"
  type = string
}

variable "container_name" {
  description = "Frontend container name"
  type= string
}

variable "host_port" {
  description = "Host port exposed for HTTP traffic"
  type = number
}

variable "network_name" {
  description = "Network to attach the frontend container to"
  type = string
}

variable "config_path" {
  description = "Host path to the nginx config file"
  type = string
}

variable "site_path" {
  description = "Directory containing the static frontend assets"
  type = string
}
