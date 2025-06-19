#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Update & install common packages
apt update -y
apt install -y postgresql-client unzip curl nginx

# Start nginx
systemctl enable nginx
systemctl start nginx
sleep 3

# Optional: Install certbot (may fail silently in cloud-init)
apt install -y certbot python3-certbot-nginx || echo "Certbot install failed (optional)"

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

# Write hostname to default nginx index page
mkdir -p /var/www/html
hostname=$(hostname)
cat <<EOF > /var/www/html/index.nginx-debian.html
<!DOCTYPE html>
<html>
<head><title>EC2 Instance</title></head>
<body><h1>Instance Hostname: $hostname</h1></body>
</html>
EOF

echo "====== Cài đặt các gói phụ thuộc ======"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "====== Thêm GPG key cho Docker ======"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "====== Cài đặt Docker Engine ======"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "====== Bật Docker khi khởi động và khởi động ngay bây giờ ======"
sudo systemctl enable docker
sudo systemctl start docker

echo "====== Thêm user hiện tại vào group docker ======"
sudo usermod -aG docker $USER

echo "Setup done" > /var/log/userdata.log
