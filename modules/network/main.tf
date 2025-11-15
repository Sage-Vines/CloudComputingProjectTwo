# builds the lil private network where all containers gossip together
# nothing fancy here: just a docker_network with a predictable subnet
resource "docker_network" "this" {
  name = var.name

  ipam_config {
    subnet = var.subnet
  }
}

