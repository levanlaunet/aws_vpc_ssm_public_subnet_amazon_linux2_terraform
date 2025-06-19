#!/bin/bash
set -e

# Update & install common packages
yum update -y
yum install -y postgresql unzip curl
sudo amazon-linux-extras install nginx1

# Start nginx
systemctl enable nginx
systemctl start nginx
sleep 3

# # Optional: Install certbot
# amazon-linux-extras enable epel
# yum install -y certbot python2-certbot-nginx || echo "Certbot install failed (optional)"

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

# Write hostname to default nginx index page
mkdir -p /usr/share/nginx/html
hostname=$(hostname)
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head><title>EC2 Instance</title></head>
<body><h1>Instance Hostname: $hostname</h1></body>
</html>
EOF

# Cài đặt Docker
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Tải plugin Docker Compose mới nhất (V2)
# mDOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
# mkdir -p $DOCKER_CONFIG/cli-plugins
# curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 \
#   -o $DOCKER_CONFIG/cli-plugins/docker-compose
# chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "Setup done" > /var/log/userdata.log
