# lil helper to remind Terraform which docker provider flavor we trust
# repeating this in each module keeps "hashicorp/docker" from sneaking back in
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

