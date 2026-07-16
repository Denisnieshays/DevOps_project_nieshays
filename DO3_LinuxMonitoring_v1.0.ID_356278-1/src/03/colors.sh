#!/bin/bash

validate_colors() {
    if [ "$1" -eq "$2" ] || [ "$3" -eq "$4" ]; then
        echo "Ошибка: Цвет фона и текста не должны совпадать"
        exit 1
    fi
}

get_text_color() {
    case $1 in
        1) echo "97" ;;   # белый
        2) echo "31" ;;   # красный
        3) echo "32" ;;   # зелёный
        4) echo "34" ;;   # синий
        5) echo "35" ;;   # фиолетовый
        6) echo "30" ;;   # чёрный
        *) echo "39" ;;   # стандартный
    esac
}

get_bg_color() {
    case $1 in
        1) echo "107" ;;  # белый
        2) echo "41" ;;   # красный
        3) echo "42" ;;   # зелёный
        4) echo "44" ;;   # синий
        5) echo "45" ;;   # фиолетовый
        6) echo "40" ;;   # чёрный
        *) echo "49" ;;   # стандартный
    esac
}