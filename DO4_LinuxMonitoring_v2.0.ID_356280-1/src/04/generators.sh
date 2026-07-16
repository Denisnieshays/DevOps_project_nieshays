#!/bin/bash

# Генерация временной метки
generate_timestamp() {
    local day="${1#0}"
    local hour=$((RANDOM % 24))
    local minute=$((RANDOM % 60))
    local second=$((RANDOM % 60))
    printf "[%02d/%s/%04d:%02d:%02d:%02d +0300]" "$day" "$(date +%b)" "$(date +%Y)" "$hour" "$minute" "$second"
}

# Генерация случайного IP-адреса
generate_ip() {
    echo "$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
}

# Генерация случайного HTTP-метода
generate_method() {
    echo "${HTTP_METHODS[$RANDOM % ${#HTTP_METHODS[@]}]}"
}

# Генерация случайного кода ответа
generate_status() {
    local codes=("${!HTTP_CODES[@]}")
    echo "${codes[$RANDOM % ${#codes[@]}]}"
}

# Генерация случайного URL
generate_url() {
    echo "${URL_PATHS[$RANDOM % ${#URL_PATHS[@]}]}"
}

# Генерация случайного User-Agent
generate_user_agent() {
    echo "${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}"
}