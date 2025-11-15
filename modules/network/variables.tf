# few args so we remember what the network should be called and where it lives
# terraform passes these down from root variables.tf
variable "name" {
  description = "Name of the Docker network"
  type = string
}

variable "subnet" {
  description = "Subnet CIDR for the Docker network"
  type = string
}

