variable "droplet_name" {
  description = "Name of the droplet"
  type        = string
  default     = "web-droplet"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "blr1"
}

variable "size" {
  description = "Droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-22-04-x64"
}