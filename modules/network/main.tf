#builds little private network where all containers gossip together
# just a docker_network with predictable subnet
resource "docker_network" "this" {
  name = var.network_name_label
  ipam_config {
    subnet = var.network_cidr_block
  }
}

