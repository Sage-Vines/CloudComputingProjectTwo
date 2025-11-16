#database inputs go here
# root module translates human-readable terraform vars into postgres env vars
#TODO: maybe add more postgres config options later?
variable "database_container_name" {
  description = "Name of Postgres container"
  type = string
}

variable "database_image_name" {
  description = "Postgres Docker image"
  type = string
}

variable "database_name_value" {
  description = "Database name"
  type = string
}

variable "database_username" {
  description = "Database user"
  type = string
}

variable "database_user_password" {
  description = "Database password"
  type = string
  sensitive = true
  #should probably validate length but whatever
}

variable "shared_network_name" {
  description = "Network name to join"
  type = string
}

variable "persistent_volume_name" {
  description = "Name of Docker volume for Postgres data"
  type = string
}

variable "internal_database_port" {
  description = "Internal Postgres port"
  type = number
}

