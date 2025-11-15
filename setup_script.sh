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
    server_name rtmp.slakhara.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
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

# Start Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Obtain Let's Encrypt certificate
sudo certbot --nginx -d rtmp.slakhara.com --non-interactive --agree-tos --email admin@slakhara.com

# firewall settings
sudo ufw allow 1935/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl reload nginx.service