#declaring docker provider source
#repeating this in every module keeps terraform from defaulting back to hashicorp/docker
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

