# RTMP Server Terraform Deployment

This repository contains Terraform scripts to deploy a fully functional RTMP server on DigitalOcean. Supports live streaming ingest via RTMP (e.g., from OBS), conversion to HLS (and DASH), with custom SSL certificates and a web player.

## Prerequisites

1. Terraform installed (v1.0+)
2. DigitalOcean account with API token
3. SSH key pair for server access
4. Domain name configured to use DigitalOcean nameservers
5. Custom SSL certificates generated for your domain in `cert/<domain>/` (cert.pem, privkey.pem, fullchain.pem)

## Configuration

### config.yaml
Main configuration file for the infrastructure:
- `droplet_name`: Name of the DigitalOcean droplet
- `region`: Deployment region (default: blr1)
- `size`: Droplet size (default: s-1vcpu-1gb)
- `image`: OS image (default: ubuntu-22-04-x64)
- `domain`: Domain name for the RTMP server (e.g., rtmp.slakhara.com)

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
2. Copies custom SSL certificates to `/etc/nginx/ssl/`
3. Configures RTMP server (port 1935, publish allowed from specific IP: 49.207.216.9)
4. Enables HLS live streaming (`/var/www/html/stream/hls/`) and DASH (`/var/www/html/stream/dash/`)
5. Sets up HTTPS server (443) with custom SSL, secure ciphers, HSTS; HTTP (80) redirects to HTTPS
6. Serves HLS/DASH streams with CORS headers
7. Deploys HLS player at `/show/hls/`
8. Configures firewall (22, 1935, 80, 443)
9. Starts and enables Nginx

## Usage

1. Clone this repository
2. Navigate to the `terraform_scripts` directory
3. Copy `.env.template` to `.env` and update:
   ```
   cp .env.template .env
   ```
4. Edit `.env` with DigitalOcean token and SSH key paths
5. Update `config.yaml` (domain, region, etc.)
6. Initialize Terraform:
   ```
   terraform init
   ```
7. Plan:
   ```
   terraform plan
   ```
8. Apply:
   ```
   terraform apply
   ```
9. Destroy (if needed):
   ```
   terraform destroy
   ```

## Streaming

### Publish Stream (e.g., OBS)
- Server: `rtmp://rtmp.slakhara.com/live`
- Stream Key: `obs_stream` (or custom)
- Full URL: `rtmp://rtmp.slakhara.com/live/obs_stream`

### View Stream
- Player: https://rtmp.slakhara.com/show/hls/hls_player.html?stream=obs_stream
- Direct HLS: https://rtmp.slakhara.com/stream/hls/obs_stream.m3u8

## Current Status
- ✅ RTMP ingest (1935)
- ✅ HLS live streaming + player
- ✅ Custom SSL (HTTPS redirect)
- ✅ CORS for streams
- ✅ Firewall & security headers
- ⏳ DASH streaming/player (dash_player.html available locally)

## Security
- Custom SSL certificates (pre-generated)
- SSH key-based access only
- UFW firewall (necessary ports only)
- HSTS enabled
- Publish restricted to specific IP
- `.env` gitignored

## Troubleshooting
- Re-deploy: `terraform apply` (re-runs setup script)
- Logs: `ssh root@<IP> tail -f /var/log/nginx/error.log`
- Test config: `nginx -t`