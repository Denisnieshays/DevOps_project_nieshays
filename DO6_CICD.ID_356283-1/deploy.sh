#!/bin/bash
set -e

echo "=== ДЕПЛОЙ НА СЕРВЕР ==="

retry() {
    for i in {1..3}; do
        if "$@"; then
            return 0
        fi
        sleep 5
    done
    return 1
}

echo "1. Копируем файл во временную директорию..."
scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 code-samples/DO nieshays@192.168.0.102:/tmp/

echo "2. Перемещаем в целевую директорию..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 nieshays@192.168.0.102 "sudo mv /tmp/DO /usr/local/bin/ && sudo chmod +x /usr/local/bin/DO"

echo "3. Проверяем работу..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 nieshays@192.168.0.102 "/usr/local/bin/DO 1"

echo "Деплой успешно завершен!"