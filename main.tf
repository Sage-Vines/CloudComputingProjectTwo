# this file glues everyting together so Terraform knows what to spin up
# think of it as the corkboard full of red string for containers
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

#docker provider is the only "cloud" we touch, so keep its declaration simple
provider "docker" {}

locals {
  #locals keep repetitive paths + ports out of the module blocks because future me forgets them
  #this port value is the single source of truth the frontend uses when proxying backend requests
  backend_internal_port = 5000
  #bind mount path for python backend so editing files doesn't require image rebuilds
  backend_code_path = abspath("${path.root}/services/backend")
  #nginx config mount path keeps the reverse-proxy rules tracked in git
  frontend_config_path = abspath("${path.root}/services/frontend/default.conf")
  #static site path feeds directly into nginx' html directory
  frontend_site_path = abspath("${path.root}/services/frontend/site")
}

module "network" {
  source = "./modules/network"

  # friendly network name & subnet so docker inspect output is predictable
  name = var.network_name
  subnet = var.network_subnet
}

module "database" {
  source = "./modules/database"

  #postgres spins up first so the backend has somewhere to stash notes
  container_name = "postgres-db"
  image_name = var.database_image
  db_name = var.database_name
  db_user = var.database_user
  db_password = var.database_password
  network_name = module.network.name
  volume_name = var.database_volume_name
  port = var.database_port
}

module "backend" {
  source = "./modules/backend"

  #backend uses the stock python image; start.sh installs psycopg and runs app.py
  image_name = var.backend_image
  container_name = "backend-service"
  internal_port = local.backend_internal_port
  code_path = local.backend_code_path
  command = ["/bin/sh", "/app/start.sh"]
  env = {
    DATABASE_HOST = module.database.container_name
    DATABASE_USER = var.database_user
    DATABASE_PASSWORD = var.database_password
    DATABASE_NAME = var.database_name
  }
  network_name = module.network.name

  depends_on = [module.database]
}

module "frontend" {
  source = "./modules/frontend"

  #frontend is just nginx serving static files and proxying /api/* calls to the backend container
  image_name = var.frontend_image
  container_name = "frontend"
  host_port = var.frontend_host_port
  network_name = module.network.name
  config_path = local.frontend_config_path
  site_path = local.frontend_site_path

  depends_on = [module.backend]
}

output "frontend_url" {
  description = "Local URL for the frontend application"
  value = "http://localhost:${var.frontend_host_port}"
}

