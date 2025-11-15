output "droplet_ip" {
  description = "The public IP address of the droplet"
  value       = digitalocean_droplet.rtmp_server.ipv4_address
}