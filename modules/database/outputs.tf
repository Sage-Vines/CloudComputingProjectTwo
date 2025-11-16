#share database container & volume names
# handy when doing docker cli work or verifying persistence
output "container_name" {
  value = docker_container.this.name
}

output "volume_name" {
  value = docker_volume.data.name
  #volume output helps with debugging persistence issues
}

