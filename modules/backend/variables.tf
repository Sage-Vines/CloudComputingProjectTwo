# all the backend knobs live here, poke them carefully
variable "backend_image_name" {
  description = "Name for the backend base image"
  type = string
}

variable "backend_container_name" {
  description = "Backend container name"
  type= string
}

variable "backend_service_port" {
  description = "Port exposed inside the Docker network"
  type = number
}

variable "backend_source_mount" {
  description = "Host path containing backend source files"
  type = string
}

variable "backend_start_command" {
  description = "Command array used to start the backend service"
  type = list(string)
  default = ["/bin/sh", "/app/start.sh"]
}

variable "backend_environment_values" {
  description = "Environment variables passed to the container"
  type= map(string)
  default = {}
}

variable "shared_network_name" {
  description = "Name of the Docker network to join"
  type = string
}

