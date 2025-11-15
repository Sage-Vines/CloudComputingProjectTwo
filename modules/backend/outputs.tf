#handy reminder name so other folks know what container to ping
#surfaced as root output so curl commands stay straightforward
output "container_name"{
  value =docker_container.this.name
}

