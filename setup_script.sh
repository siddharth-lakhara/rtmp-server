export PATH=$PATH:/usr/bin

# install nginx
sudo apt update
sudo apt install -y nginx
sudo apt install libnginx-mod-rtmp

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
        }

    }
}
EOF

# Create site configuration
sudo tee /etc/nginx/sites-available/rtmpserver > /dev/null <<EOF
server {
    listen 8088;

    location / {
        add_header Cache-Control no-cache;
        add_header Access-Control-Allow-Origin *;

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }

        root /var/www/html/hls;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/rtmpserver /etc/nginx/sites-enabled/

# Include RTMP config in main nginx config
sudo tee -a /etc/nginx/nginx.conf > /dev/null <<EOF

include /etc/nginx/rtmp.conf;
EOF

# Create directory for HLS
sudo mkdir -p /var/www/html/hls

# firewall settings
sudo ufw allow 1935/tcp
sudo ufw allow 80/tcp
sudo ufw allow 8088/tcp
sudo systemctl reload nginx.service