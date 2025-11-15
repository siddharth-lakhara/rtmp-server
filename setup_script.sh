export PATH=$PATH:/usr/bin

# install nginx
sudo apt update
sudo apt install -y nginx
sudo apt install -y libnginx-mod-rtmp
sudo apt install -y certbot python3-certbot-nginx

# Create RTMP configuration
sudo tee /etc/nginx/rtmp.conf > /dev/null <<EOF
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        allow publish 49.207.216.9;

        application live {
            live on;
            record off;

            # HLS settings
            hls on;
            hls_path /var/www/html/hls;
            hls_fragment 3;
            hls_playlist_length 60;
            
            # HTTPS HLS settings
            hls_variant _low BANDWIDTH=288000;
            hls_variant _mid BANDWIDTH=448000;
            hls_variant _high BANDWIDTH=1152000;
        }

    }
}
EOF

# Create site configuration
sudo tee /etc/nginx/sites-available/rtmpserver > /dev/null <<EOF
server {
    listen 80;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    
    # Self-signed certificate for IP address
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    
    location / {
        add_header Cache-Control no-cache;
        add_header Access-Control-Allow-Origin *;

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }

        root /var/www/html/hls;
    }
    
    location /hls {
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
        root /var/www/html;
        add_header Cache-Control no-cache;
        add_header Access-Control-Allow-Origin *;
    }
}
EOF

# Disable default site and enable our site
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/rtmpserver /etc/nginx/sites-enabled/

# Include RTMP config in main nginx config
sudo tee -a /etc/nginx/nginx.conf > /dev/null <<EOF

include /etc/nginx/rtmp.conf;
EOF

# Create directory for HLS
sudo mkdir -p /var/www/html/hls
sudo mkdir -p /var/www/certbot

# Generate self-signed certificate for IP address
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/CN=localhost"

# firewall settings
sudo ufw allow 1935/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl reload nginx.service