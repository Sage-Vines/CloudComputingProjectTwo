#sets up postgres plus a little volume so data doesnt vanish each restart
resource "docker_volume" "data" {
  name = var.persistent_volume_name
}

resource "docker_image" "this" {
  name = var.database_image_name
  keep_locally = true
}

resource "docker_container" "this" {
  name = var.database_container_name
  image = docker_image.this.image_id
  restart = "unless-stopped"
  env = [
    "POSTGRES_DB=${var.database_name_value}",
    "POSTGRES_USER=${var.database_username}",
    "POSTGRES_PASSWORD=${var.database_user_password}",
  ]
  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.data.name
    type = "volume"
  }
  networks_advanced {
    name = var.shared_network_name
  }
  ports {
    internal = var.internal_database_port
  }
}

