#need this so terraform knows which docker provider to grab
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

