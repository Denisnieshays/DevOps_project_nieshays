#!/bin/bash

# Цветовая схема по умолчанию
DEFAULT_COL1_BG=6  # black
DEFAULT_COL1_FG=1  # white
DEFAULT_COL2_BG=2  # red
DEFAULT_COL2_FG=4  # blue

# Функция для получения названия цвета
get_color_name() {
    case $1 in
        1) echo "white";;
        2) echo "red";;
        3) echo "green";;
        4) echo "blue";;
        5) echo "purple";;
        6) echo "black";;
        *) echo "unknown";;
    esac
}

# Функции для получения ANSI цветов
get_text_color() {
    case $1 in
        1) echo "37";;  # white
        2) echo "31";;  # red
        3) echo "32";;  # green
        4) echo "34";;  # blue
        5) echo "35";;  # purple
        6) echo "30";;  # black
        *) echo "37";;  # default white
    esac
}

get_bg_color() {
    case $1 in
        1) echo "47";;  # white
        2) echo "41";;  # red
        3) echo "42";;  # green
        4) echo "44";;  # blue
        5) echo "45";;  # purple
        6) echo "40";;  # black
        *) echo "40";;  # default black
    esac
}

# Загрузка конфигурации
load_config() {
    local CONFIG_FILE="config.conf"
    
    if [ -f "$CONFIG_FILE" ] && [ -r "$CONFIG_FILE" ]; then
        while IFS='=' read -r key value; do
            case "$key" in
                column1_background) column1_background="$value" ;;
                column1_font_color) column1_font_color="$value" ;;
                column2_background) column2_background="$value" ;;
                column2_font_color) column2_font_color="$value" ;;
            esac
        done < "$CONFIG_FILE"
    else
        echo "Конфигурационный файл не найден, используются значения по умолчанию" >&2
    fi

    # Установка цветов с проверкой
    COL1_BG=${column1_background:-$DEFAULT_COL1_BG}
    COL1_FG=${column1_font_color:-$DEFAULT_COL1_FG}
    COL2_BG=${column2_background:-$DEFAULT_COL2_BG}
    COL2_FG=${column2_font_color:-$DEFAULT_COL2_FG}
}

# Функция для вывода цветовой схемы
print_color_scheme() {
    echo -e "\nЦветовая схема:"
    
    if [ -z "${column1_background+x}" ]; then
        echo "Column 1 background = default ($(get_color_name "$DEFAULT_COL1_BG"))"
    else
        echo "Column 1 background = $COL1_BG ($(get_color_name "$COL1_BG"))"
    fi

    if [ -z "${column1_font_color+x}" ]; then
        echo "Column 1 font color = default ($(get_color_name "$DEFAULT_COL1_FG"))"
    else
        echo "Column 1 font color = $COL1_FG ($(get_color_name "$COL1_FG"))"
    fi

    if [ -z "${column2_background+x}" ]; then
        echo "Column 2 background = default ($(get_color_name "$DEFAULT_COL2_BG"))"
    else
        echo "Column 2 background = $COL2_BG ($(get_color_name "$COL2_BG"))"
    fi

    if [ -z "${column2_font_color+x}" ]; then
        echo "Column 2 font color = default ($(get_color_name "$DEFAULT_COL2_FG"))"
    else
        echo "Column 2 font color = $COL2_FG ($(get_color_name "$COL2_FG"))"
    fi
}