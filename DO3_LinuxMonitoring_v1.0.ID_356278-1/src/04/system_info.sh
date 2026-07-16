#!/bin/bash

collect_system_info() {
    # Основная системная информация
    SYSTEM_INFO=(
        "ИМЯ ХОСТА = $(hostname)"
        "ЧАСОВОЙ ПОЯС = $(timedatectl | grep "Time zone" | awk '{print $3, $4, $5}')"
        "ПОЛЬЗОВАТЕЛЬ = $(whoami)"
        "ОС = $(lsb_release -d | cut -f2-)"
        "ДАТА = $(date "+%d %B %Y %H:%M:%S")"
        "UPTIME = $(uptime -p | sed 's/up //')"
        "UPTIME_SEC = $(awk '{print $1}' /proc/uptime)"
    )

    # Сетевая информация
    local ip_line=$(ip a | grep -w "inet" | grep -v "127.0.0.1" | head -n 1)
    NETWORK_INFO=(
        "IP = $(echo "$ip_line" | awk '{print $2}' | cut -d'/' -f1)"
        "МАСКА = $(echo "$ip_line" | awk '{print $2}' | cut -d'/' -f2)"
        "GATEWAY = $(ip route | grep default | awk '{print $3}')"
    )

    # Информация о памяти
    local mem_info=$(free -m | awk '/Mem:/')
    MEMORY_INFO=(
        "ОБЩИЙ ОБЪЕМ ОЗУ = $(echo "$mem_info" | awk '{printf "%.3f", $2/1024}') ГБ"
        "RAM_USED = $(echo "$mem_info" | awk '{printf "%.3f", $3/1024}') ГБ"
        "RAM_FREE = $(echo "$mem_info" | awk '{printf "%.3f", $4/1024}') ГБ"
    )

    # Информация о диске
    local disk_info=$(df / -BM | awk 'NR==2')
    DISK_INFO=(
        "SPACE_ROOT = $(echo "$disk_info" | awk '{printf "%.2f", $2/1}') МБ"
        "SPACE_ROOT_USED = $(echo "$disk_info" | awk '{printf "%.2f", $3/1}') МБ"
        "SPACE_ROOT_FREE = $(echo "$disk_info" | awk '{printf "%.2f", $4/1}') МБ"
    )
}