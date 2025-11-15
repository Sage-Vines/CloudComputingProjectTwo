#spitting out the basic network facts for other modules to reuse
#mainly so backend/frontend modules know which docker network to join
output "id" {
  value = docker_network.this.id
}

output "name" {
  value = docker_network.this.name
}

