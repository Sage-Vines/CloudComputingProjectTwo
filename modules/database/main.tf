#sets up postgres plus a little volume so data doesnt vanish each restart
resource "docker_volume" "data" {
  name = var.volume_name
}

resource "docker_image" "this" {
  name = var.image_name
  keep_locally = true
}

resource "docker_container" "this" {
  name= var.container_name
  image = docker_image.this.image_id

  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.data.name
    type = "volume"
  }

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = var.port
  }
}

