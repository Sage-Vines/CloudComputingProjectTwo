# builds nginx front door and points it at whatever backend we say
#also shoves static site in place so no extra image build needed
resource "docker_image" "this" {
  name = var.frontend_image_name
  keep_locally = true
}

# runs nginx straight from registry, mounts config & site bundle
resource "docker_container" "this" {
  name= var.frontend_container_name
  image = docker_image.this.image_id

  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.frontend_host_port
  }

  mounts {
    target = "/etc/nginx/conf.d/default.conf"
    source = var.nginx_config_path
    type = "bind"
  }

  mounts {
    target = "/usr/share/nginx/html"
    source = var.static_site_path
    type = "bind"
  }

  networks_advanced {
    name = var.shared_network_name
  }
}

