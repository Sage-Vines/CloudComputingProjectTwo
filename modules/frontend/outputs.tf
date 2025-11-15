# remind us what nginx box is called so users dont guess
output "container_name" {
  value = docker_container.this.name
}

