#all backend variables live here, poke them carefully
#TODO: maybe add validation blocks later?
variable "backend_image_name" {
  description = "Name for backend base image"
  type = string
  #default = "python:3.11-slim"  #test default
}

variable "backend_container_name" {
  description = "Backend container name"
  type = string
}

variable "backend_service_port" {
  description = "Port exposed inside Docker network"
  type = number
}

variable "backend_source_mount" {
  description = "Host path containing backend source files"
  type = string
}

variable "backend_start_command" {
  description = "Command array used to start backend service"
  type = list(string)
  default = ["/bin/sh", "/app/start.sh"]
  #default = ["python", "/app/app.py"]  #direct start, might test later
}

variable "backend_environment_values" {
  description = "Environment variables passed to container"
  type = map(string)
  default = {}
}

variable "shared_network_name" {
  description = "Name of Docker network to join"
  type = string
}

