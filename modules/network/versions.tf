#copied this from backend module, keeps things consistent
terraform {
  required_providers{
    docker = {
      source= "kreuzwerker/docker"
    }
  }
}

