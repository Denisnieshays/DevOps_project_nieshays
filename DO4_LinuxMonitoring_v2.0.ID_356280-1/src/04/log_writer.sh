#!/bin/bash

# Генерация лога за один день
generate_day_log() {
    local day="$1"
    local filename="nginx_access_$(date +%Y-%m-%d -d "-$((5-day)) days").log"
    local entries=$((RANDOM % 901 + 100)) # От 100 до 1000 записей
    
    echo "Генерация файла $filename с $entries записями..." >&2
    
    # Генерируем все записи для дня
    local logs=()
    for ((i=0; i<entries; i++)); do
        local ip=$(generate_ip)
        local timestamp=$(generate_timestamp "$day")
        local method=$(generate_method)
        local url=$(generate_url)
        local status=$(generate_status)
        local agent=$(generate_user_agent)
        
        logs+=("$ip - - $timestamp \"$method $url HTTP/1.1\" $status $((RANDOM % 5000 + 500)) \"-\" \"$agent\"")
    done
    
    # Сортируем логи по времени
    IFS=$'\n' sorted_logs=($(sort <<<"${logs[*]}"))
    unset IFS
    
    # Записываем в файл
    printf "%s\n" "${sorted_logs[@]}" > "$filename"
    echo "Файл $filename создан успешно" >&2
}