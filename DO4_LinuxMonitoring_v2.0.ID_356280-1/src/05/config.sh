#!/bin/bash

# Путь к лог-файлу
LOG_FILE="/home/nieshays/DO4/04/nginx_access_2025-08-09.log"

# Проверка существования лог-файла
if [ ! -f "$LOG_FILE" ]; then
    echo "Ошибка: Лог-файл $LOG_FILE не найден"
    exit 1
fi