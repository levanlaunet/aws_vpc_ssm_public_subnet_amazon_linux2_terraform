#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

echo "== START user_data =="

dnf update -y
dnf install -y postgresql15 unzip -y
dnf install -y nginx -y

# Create index.html with hostname
mkdir -p /usr/share/nginx/html
hostname=$(hostname)
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head><title>EC2 Instance</title></head>
<body><h1>Instance Hostname: $hostname</h1></body>
</html>
EOF

systemctl enable nginx
systemctl start nginx

# Optional: Certbot (only if available)
dnf install -y certbot python3-certbot-nginx || echo "[WARN] Certbot not found in repo."

echo "====== Cài đặt Docker ======"
sudo dnf install -y docker

echo "====== Bật và khởi động Docker ======"
sudo systemctl enable docker
sudo systemctl start docker

echo "====== Thêm user hiện tại vào nhóm docker ======"
sudo usermod -aG docker ec2-user

echo "====== Kiểm tra Docker ======"
docker --version

echo "====== Cài Docker Compose v2 (dùng plugin chính thức) ======"
# Docker Compose v2 đi kèm docker-ce nếu có plugin
# Trên Amazon Linux 2023 có thể thiếu, nên ta cài thủ công bản v2.24.6 (hoặc bản mới hơn)

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "== DONE =="
