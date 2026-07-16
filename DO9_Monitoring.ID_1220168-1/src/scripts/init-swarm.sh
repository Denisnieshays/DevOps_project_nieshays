#!/bin/bash
echo "=== Initializing Docker Swarm ==="

# Даем немного времени на запуск Docker
sleep 10

# Инициализируем Swarm
docker swarm init --advertise-addr 192.168.56.10

# Сохраняем токен для worker-ов в файл
docker swarm join-token worker -q > /vagrant/worker_token.txt

echo "=== Docker Swarm initialized ==="
echo "Worker token: $(cat /vagrant/worker_token.txt)"
echo "Token saved to /vagrant/worker_token.txt"