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
            hls_path /var/www/html/stream/hls;
            hls_fragment 3;
            hls_playlist_length 60;
            
            # HTTPS HLS settings
            hls_variant _low BANDWIDTH=288000;
            hls_variant _mid BANDWIDTH=448000;
            hls_variant _high BANDWIDTH=1152000;
            
            # DASH settings
            dash on;
            dash_path /var/www/html/stream/dash;
            dash_fragment 3;
            dash_playlist_length 60;
        }

    }
}
EOF

# Create site configuration
sudo tee /etc/nginx/sites-available/rtmpserver > /dev/null <<EOF
server {
    listen 80;
    server_name rtmp.slakhara.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location /stream/hls {
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
        root /var/www/html/stream;
        add_header Cache-Control no-cache;
        add_header Access-Control-Allow-Origin *;
    }
    
    location /stream/dash {
        types {
            application/dash+xml mpd;
            video/mp4 mp4;
        }
        root /var/www/html/stream;
        add_header Cache-Control no-cache;
        add_header Access-Control-Allow-Origin *;
    }
    
    location /show/hls {
        root /var/www/html/player;
        index hls_player.html;
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Disable default site and enable our site
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/rtmpserver /etc/nginx/sites-enabled/

# Create directory for HLS
sudo mkdir -p /var/www/html/stream/hls
sudo mkdir -p /var/www/html/stream/dash
sudo mkdir -p /var/www/html/player
sudo mkdir -p /var/www/certbot

# firewall settings
sudo ufw allow 22/tcp
sudo ufw allow 1935/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Include RTMP config in main nginx config
sudo tee -a /etc/nginx/nginx.conf > /dev/null <<EOF

include /etc/nginx/rtmp.conf;
EOF

# Start Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Function to obtain Let's Encrypt certificate with retry
obtain_certificate() {
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts to obtain Let's Encrypt certificate..."
        if sudo certbot --nginx -d rtmp.slakhara.com --non-interactive --agree-tos --email admin@slakhara.com; then
            echo "Successfully obtained Let's Encrypt certificate"
            return 0
        else
            echo "Failed to obtain certificate, waiting 30 seconds before retry..."
            sleep 30
            attempt=$((attempt + 1))
        fi
    done
    
    echo "Failed to obtain Let's Encrypt certificate after $max_attempts attempts"
    echo "Exiting setup script"
    exit 1
}

# Obtain Let's Encrypt certificate
# obtain_certificate

sudo systemctl reload nginx.service