# Kinda messy list of knobs you can tweak, secrets go in tfvars
#this whole file is basically control panel for local cloud
variable "network_name" {
  description = "Custom Docker network"
  type = string
  default= "local-cloud"
}

variable "network_subnet" {
  description = "Private subnet used by Docker network"
  type= string
  default = "172.28.0.0/16"
}

variable "frontend_host_port" {
  description = "Host port exposed for frontend"
  type = number
  default= 8080
}

variable "backend_image" {
  description = "Base image used for backend microservice"
  type= string
  default = "python:3.11-slim"
}

variable "frontend_image" {
  description ="Image used for nginx frontend"
  type = string
  default ="nginx:alpine"
}

variable "database_image" {
  description = "Docker image for Postgres"
  type= string
  default = "postgres:15-alpine"
}

variable "database_name" {
  description = "Postgres database"
  type = string
  default = "app_db"
}

variable "database_user" {
  description ="Database user"
  type = string
  default= "app_user"
}

variable "database_password" {
  description = "Database password"
  type = string
  sensitive = true
}

variable "database_volume_name" {
  description = "Name for persistent Postgres volume"
  type= string
  default = "postgres-data"
}

variable "database_port" {
  description = "Internal Postgres port"
  type = number
  default = 5432
}

