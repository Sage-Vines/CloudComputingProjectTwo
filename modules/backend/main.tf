#cooks backend container straight from registry and binds local code
# since we bind mount repo folder, docker never needs to rebuild for code tweaks
resource "docker_image" "this" {
  name = var.backend_image_name
  keep_locally = true
  #keep_locally = false  #might change this later to save space
}

#spins up python container, bind mounts app folder, runs start script
# command & env fields get injected from root module
resource "docker_container" "this" {
  name = var.backend_container_name
  image = docker_image.this.image_id
  restart = "unless-stopped"
  command = var.backend_start_command
  env = [for k, v in var.backend_environment_values : "${k}=${v}"]
  mounts {
    target = "/app"
    source = var.backend_source_mount
    type = "bind"
  }
  networks_advanced {
    name = var.shared_network_name
  }
  working_dir = "/app"
  ports {
    internal = var.backend_service_port
    #external = 5000  #could expose externally but not needed
  }
}

