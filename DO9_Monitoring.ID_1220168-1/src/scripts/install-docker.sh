#!/bin/bash
echo "=== Installing Docker ==="
apt-get update
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
# Создаем группу docker, если она не существует
groupadd docker || true
usermod -aG docker vagrant
echo "=== Docker installed successfully ==="
docker --version