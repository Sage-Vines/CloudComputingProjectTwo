#database inputs go here
#root module translates human-readable terraform vars into postgres env vars
variable "container_name" {
  description = "Name of the Postgres container"
  type = string
}

variable "image_name" {
  description = "Postgres Docker image"
  type = string
}

variable "db_name" {
  description = "Database name"
  type = string
}

variable "db_user" {
  description = "Database user"
  type = string
}

variable "db_password" {
  description = "Database password"
  type= string
  sensitive = true
}

variable "network_name" {
  description = "Network name to join"
  type = string
}

variable "volume_name" {
  description = "Name of the Docker volume for Postgres data"
  type= string
}

variable "port" {
  description = "Internal Postgres port"
  type = number
}

