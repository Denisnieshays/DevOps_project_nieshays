#!/bin/bash

# Все уникальные IP-адреса
unique_ips() {
    echo "Уникальные IP-адреса:"
    awk '{print $1}' "$LOG_FILE" | sort -u
}