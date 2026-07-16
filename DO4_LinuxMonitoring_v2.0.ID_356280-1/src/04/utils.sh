#!/bin/bash

# Проверка зависимостей
check_dependencies() {
    local deps=("date" "sort" "printf")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Ошибка: Необходима утилита $dep" >&2
            exit 1
        fi
    done
}

# Инициализация
initialize() {
    check_dependencies
    mkdir -p "$(dirname "$0")/logs"
}