output "droplet_ip" {
  description = "The public IP address of the droplet"
  value       = digitalocean_droplet.rtmp_server.ipv4_address
}

output "domain_name" {
  description = "The domain name pointing to the droplet"
  value       = digitalocean_domain.rtmp_domain.name
}