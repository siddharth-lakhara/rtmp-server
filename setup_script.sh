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
        # allow publish 127.0.0.1;
        # deny publish all;
        
        application live {
            live on;
            record off;
        }

        application show {
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

# Include RTMP config in main nginx config
sudo tee -a /etc/nginx/nginx.conf > /dev/null <<EOF

include /etc/nginx/rtmp.conf;
EOF

# Create directory for HLS
sudo mkdir -p /var/www/html/hls
sudo chown www-data:www-data /var/www/html/hls

# firewall settings
sudo ufw allow 1935/tcp
sudo ufw allow 80/tcp
sudo systemctl reload nginx.service