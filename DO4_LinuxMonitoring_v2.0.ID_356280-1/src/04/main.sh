#!/bin/bash

# Подключаем модули
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/generators.sh"
source "$(dirname "$0")/log_writer.sh"

# Основная функция
generate_nginx_logs() {
    # Генерируем логи за 5 дней
    for day in {5..1}; do
        generate_day_log "$day"
    done
    
    echo "Генерация логов завершена. Создано 5 файлов." >&2
}

# Запуск основной функции
generate_nginx_logs