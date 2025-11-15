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
  
  provisioner "file" {
    source      = "${path.module}/../setup_script.sh"
    destination = "/tmp/setup_script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_script.sh",
      "/tmp/setup_script.sh"
    ]
  }
}

# resource "digitalocean_domain" "rtmp_domain" {
#   name       = local.config.domain
# }
# 
# resource "digitalocean_record" "rtmp_record" {
#   domain = digitalocean_domain.rtmp_domain.name
#   type   = "A"
#   name   = "@"
#   value  = digitalocean_droplet.rtmp_server.ipv4_address
# }
# 
# resource "digitalocean_record" "www_record" {
#   domain = digitalocean_domain.rtmp_domain.name
#   type   = "A"
#   name   = "www"
#   value  = digitalocean_droplet.rtmp_server.ipv4_address
# }