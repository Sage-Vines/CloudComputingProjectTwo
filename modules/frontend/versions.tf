#same provider pinning thing, just repeating so future me remembers
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

