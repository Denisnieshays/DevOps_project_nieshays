#!/bin/bash

get_system_info() {
    echo "ИМЯ ХОСТА = $(hostname)"
    echo "ЧАСОВОЙ ПОЯС = $(timedatectl | grep "Time zone" | awk '{print $3, $4, $5}')"
    echo "ПОЛЬЗОВАТЕЛЬ = $(whoami)"
    echo "ОС = $(lsb_release -d | cut -f2-)"
    echo "ДАТА = $(date "+%d %B %Y %H:%M:%S")"
    echo "UPTIME = $(uptime -p)"
    echo "UPTIME_SEC = $(awk '{print $1}' /proc/uptime)"
}

get_network_info() {
    local ip_info=$(ip a | grep -w "inet" | grep -v "127.0.0.1" | head -n 1)
    echo "IP = $(echo "$ip_info" | awk '{print $2}' | cut -d'/' -f1)"
    echo "МАСКА = $(echo "$ip_info" | awk '{print $2}' | cut -d'/' -f2)"
    echo "GATEWAY = $(ip route | grep default | awk '{print $3}')"
}