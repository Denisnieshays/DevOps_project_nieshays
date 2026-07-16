#!/bin/bash
echo "=== Joining Docker Swarm ==="

# Ждем пока manager создаст токен
sleep 30

# Пытаемся получить токен и присоединиться к Swarm
MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if [ -f /vagrant/worker_token.txt ]; then
        WORKER_TOKEN=$(cat /vagrant/worker_token.txt)
        MANAGER_IP="192.168.56.10"
        
        echo "Joining Swarm with token: $WORKER_TOKEN"
        docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377
        
        if [ $? -eq 0 ]; then
            echo "=== Successfully joined Swarm ==="
            break
        else
            echo "Failed to join Swarm, retrying..."
        fi
    else
        echo "Waiting for worker token... (attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
        sleep 10
    fi
    RETRY_COUNT=$((RETRY_COUNT+1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "=== ERROR: Failed to join Swarm after $MAX_RETRIES attempts ==="
    echo "You may need to join manually using: docker swarm join --token <TOKEN> 192.168.56.10:2377"
fi