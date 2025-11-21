#these outputs are like friendly reminders of what got made
# they show up after terraform apply so you know which containers/URLs to "poke"
output "network_name" {
  description = "Docker network hosting services"
  value = module.network.name
  #could add more outputs but these are the important ones
}

output "backend_container" {
  description = "Name of backend container"
  value = module.backend.container_name
}

output "database_container" {
  description = "Name of Postgres container"
  value = module.database.container_name
}

