# all the backend knobs live here, poke them carefully
variable "image_name" {
  description = "Name for the backend base image"
  type = string
}

variable "container_name" {
  description = "Backend container name"
  type= string
}

variable "internal_port" {
  description = "Port exposed inside the Docker network"
  type = number
}

variable "code_path" {
  description = "Host path containing backend source files"
  type = string
}

variable "command" {
  description = "Command array used to start the backend service"
  type = list(string)
  default = ["/bin/sh", "/app/start.sh"]
}

variable "env" {
  description = "Environment variables passed to the container"
  type= map(string)
  default = {}
}

variable "network_name" {
  description = "Name of the Docker network to join"
  type = string
}

