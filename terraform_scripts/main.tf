locals {
  config = yamldecode(file("${path.module}/config.yaml"))
  env_vars = {
    for pair in split("\n", file("${path.module}/.env")) :
    split("=", pair)[0] => split("=", pair)[1] if length(split("=", pair)) == 2
  }
}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = local.env_vars.do_token
}

resource "digitalocean_ssh_key" "terraform" {
  name       = "terraform"
  public_key = file(local.env_vars.ssh_key_pub)
}