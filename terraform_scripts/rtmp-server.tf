resource "digitalocean_droplet" "rtmp_server" {
  image  = local.config.image
  name   = local.config.droplet_name
  region = local.config.region
  size   = local.config.size

  ssh_keys = [
    digitalocean_ssh_key.terraform.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(local.env_vars.ssh_key_pvt)
    timeout = "2m"
  }
  
  provisioner "remote-exec" {
    
  }
}