#builds little private network where all containers gossip together
# just a docker_network with predictable subnet
resource "docker_network" "this" {
  name = var.network_name_label
  #driver = "bridge"  #default, could specify explicitly
  ipam_config {
    subnet = var.network_cidr_block
    #gateway = "172.28.0.1"  #might need to set this later
  }
}

