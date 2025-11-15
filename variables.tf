# Kinda messy list of knobs you can tweak, secrets go in tfvars
# this whole file is basically the control panel for the local cloud
variable "network_name" {
  description = "Name of the custom Docker network"
  type= string
  default = "local-cloud"
}

variable "network_subnet" {
  description = "Private subnet used by the Docker network"
  type = string
  default = "172.28.0.0/16"
}

variable "frontend_host_port" {
  description = "Host port exposed for the frontend"
  type = number
  default = 8080
}

variable "backend_image" {
  description = "Base image used for the backend microservice"
  type = string
  default = "python:3.11-slim"
}

variable "frontend_image" {
  description = "Image used for the nginx frontend"
  type = string
  default = "nginx:alpine"
}

variable "database_image" {
  description = "Docker image to use for Postgres"
  type = string
  default = "postgres:15-alpine"
}

variable "database_name" {
  description = "Name of the Postgres database"
  type = string
  default = "app_db"
}

variable "database_user" {
  description = "Database user name"
  type = string
  default = "app_user"
}

variable "database_password" {
  description = "Database password (stored in tfvars)"
  type = string
  sensitive = true
}

variable "database_volume_name" {
  description = "Name for the persistent Postgres volume"
  type = string
  default = "postgres-data"
}

variable "database_port" {
  description = "Internal Postgres port"
  type = number
  default = 5432
}

