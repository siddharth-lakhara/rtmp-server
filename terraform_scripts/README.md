# RTMP Server Terraform Deployment

This repository contains Terraform scripts to deploy an RTMP server on DigitalOcean with automated SSL certificate management.

## Prerequisites

1. Terraform installed (v1.0+)
2. DigitalOcean account with API token
3. SSH key pair for server access
4. Domain name configured to use DigitalOcean nameservers

## Configuration

### config.yaml
Main configuration file for the infrastructure:
- `droplet_name`: Name of the DigitalOcean droplet
- `region`: Deployment region (default: blr1)
- `size`: Droplet size (default: s-1vcpu-1gb)
- `image`: OS image (default: ubuntu-22-04-x64)
- `domain`: Domain name for the RTMP server

### Environment Variables (.env)
Sensitive configuration stored in `.env` file (excluded from version control):
- `do_token`: DigitalOcean API token
- `ssh_key_pub`: Path to SSH public key
- `ssh_key_pvt`: Path to SSH private key

## Terraform Resources

The deployment creates the following resources:
1. DigitalOcean Droplet with specified configuration
2. Reserved IP address for static access
3. SSH key registration for secure access
4. Domain registration with A record pointing to the server
5. Reserved IP assignment to the droplet

## Setup Script

The `setup_script.sh` performs the following actions:
1. Installs Nginx with RTMP module
2. Configures RTMP streaming with HLS support
3. Sets up firewall rules for RTMP (1935), HTTP (80), and HTTPS (443)
4. Configures Let's Encrypt SSL certificate (commented out by default)
5. Enables and starts Nginx service

## Usage

1. Clone this repository
2. Navigate to the terraform_scripts directory
3. Copy the `.env.template` file to `.env` and update with your values:
   ```
   cp .env.template .env
   ```
4. Update the `.env` file with your DigitalOcean token and SSH key paths
5. Update `config.yaml` with your desired configuration
5. Initialize Terraform:
   ```
   terraform init
   ```

6. Plan the infrastructure:
   ```
   terraform plan
   ```

7. Apply the infrastructure:
   ```
   terraform apply
   ```

8. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Security

- The `.env` file contains sensitive information and is excluded from version control via `.gitignore`
- SSH key-based authentication is used for server access
- Firewall rules restrict access to only necessary ports
- Let's Encrypt SSL certificate support is included but commented out by default