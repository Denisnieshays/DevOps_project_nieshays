#!/bin/bash

# Инициализация лог-файла
init_log_file() {
    local base_path="$1"
    log_file="$base_path/creation_log_$(date +'%d%m%Y').txt"
    echo "Лог создания файлов и папок" > "$log_file"
    echo "Дата начала: $(date)" >> "$log_file"
    echo "Параметры: $@" >> "$log_file"
    echo "" >> "$log_file"
}

# Запись сообщения в лог
log_message() {
    local message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $message" >> "$log_file"
}

# Завершение лога
complete_log() {
    echo "" >> "$log_file"
    echo "Завершено: $(date)" >> "$log_file"
    echo "Лог сохранен в: $log_file"
}