#few args so we remember what network should be called and where it lives
# terraform passes these down from root variables.tf
variable "network_name_label" {
  description = "Name of Docker network"
  type = string
}

variable "network_cidr_block" {
  description = "Subnet CIDR for Docker network"
  type = string
}

