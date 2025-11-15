#cooks the backend container straight from registry and binds local code
#since we bind mount the repo folder, docker never needs to rebuild for code tweaks
resource "docker_image" "this" {
  name= var.image_name
  keep_locally = true
}

#spins up python container, bind mounts app folder, and runs our start script
#command & env fields get injected from root module so we can reuse this module again
resource "docker_container" "this" {
  name = var.container_name
  image = docker_image.this.image_id

  restart = "unless-stopped"
  command = var.command

  env = [
    for k, v in var.env : "${k}=${v}"
  ]

  mounts {
    target = "/app"
    source = var.code_path
    type = "bind"
  }

  networks_advanced {
    name = var.network_name
  }

  working_dir = "/app"

  ports {
    internal = var.internal_port
  }
}

