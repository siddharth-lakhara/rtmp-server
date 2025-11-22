resource "digitalocean_reserved_ip" "rtmp_server_ip" {
  region = local.config.region
}

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
    source      = "${path.module}/setup_script.sh"
    destination = "/tmp/setup_script.sh"
  }
  
  provisioner "file" {
    source      = "${path.module}/../player/hls_player.html"
    destination = "/tmp/hls_player.html"
  }

  # provisioner "file" {
  #   source      = "${path.module}/../cert/rtmp.slakhara.com/cert.pem"
  #   destination = "/tmp/cert.pem"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/../cert/rtmp.slakhara.com/privkey.pem"
  #   destination = "/tmp/privkey.pem"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/../cert/rtmp.slakhara.com/fullchain.pem"
  #   destination = "/tmp/fullchain.pem"
  # }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/www/html/player",
      "cp /tmp/hls_player.html /var/www/html/player/",
      "chmod +x /tmp/setup_script.sh",
      "/tmp/setup_script.sh"
    ]
  }
}

resource "digitalocean_reserved_ip_assignment" "rtmp_server_ip_assignment" {
  ip_address = digitalocean_reserved_ip.rtmp_server_ip.ip_address
  droplet_id = digitalocean_droplet.rtmp_server.id
}

resource "digitalocean_domain" "rtmp_domain" {
  name       = local.config.domain
}

resource "digitalocean_record" "rtmp_record" {
  domain = digitalocean_domain.rtmp_domain.name
  type   = "A"
  name   = "@"
  value  = digitalocean_reserved_ip.rtmp_server_ip.ip_address
  ttl    = 45
}

# resource "digitalocean_certificate" "custom_cert" {
#   name              = "rtmp-slakhara-com-custom-cert"
#   type              = "custom"
#   private_key       = file("${path.module}/../cert/rtmp.slakhara.com/privkey.pem")
#   leaf_certificate  = file("${path.module}/../cert/rtmp.slakhara.com/cert.pem")
#   certificate_chain = file("${path.module}/../cert/rtmp.slakhara.com/fullchain.pem")
# }

# resource "digitalocean_loadbalancer" "public_lb" {
#   name   = "my-rtmp-loadbalancer"
#   region = "nyc3" # Replace with your region
  
#   # ... other loadbalancer config

#   forwarding_rule {
#     entry_port      = 443
#     entry_protocol  = "https"
#     target_port     = 80 # Or 443 if Nginx handles TLS passthrough
#     target_protocol = "http" # Or "https" for end-to-end encryption
    
#     # *** Reference the custom certificate ID here ***
#     certificate_id  = digitalocean_certificate.custom_cert.id
#   }
  
#   # Forward HTTP to HTTPS (optional but recommended)
#   redirect_http_to_https = true
  
#   # ... other loadbalancer config
# }