# builds the lil private network where all containers gossip together
# nothing fancy here: just a docker_network with a predictable subnet
resource "docker_network" "this" {
  name = var.network_name_label

  ipam_config {
    subnet = var.network_cidr_block
  }
}

