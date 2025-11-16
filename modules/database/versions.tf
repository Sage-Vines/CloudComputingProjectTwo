#same as other modules, need kreuzwerker not hashicorp
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

