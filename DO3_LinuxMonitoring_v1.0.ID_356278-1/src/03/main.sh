#!/bin/bash

# Импорт модулей
source ./colors.sh
source ./system_info.sh
source ./memory_info.sh
source ./disk_info.sh
source ./output.sh

# Настройка локали
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

# Проверка аргументов
if [ "$#" -ne 4 ]; then
    echo "Использование: $0 <фон_заголовков> <цвет_заголовков> <фон_значений> <цвет_значений>"
    echo "Доступные цвета: 1-6 (белый, красный, зелёный, синий, фиолетовый, чёрный)"
    exit 1
fi

# Установка цветов
validate_colors "$1" "$2" "$3" "$4"
title_bg=$(get_bg_color "$1")
title_fg=$(get_text_color "$2")
value_bg=$(get_bg_color "$3")
value_fg=$(get_text_color "$4")

# Сбор и вывод информации
get_system_info | while read -r line; do
    print_colored_line "${line%=*}= " "${line#*=}"
done

get_network_info | while read -r line; do
    print_colored_line "${line%=*}= " "${line#*=}"
done

get_memory_info | while read -r line; do
    print_colored_line "${line%=*}= " "${line#*=}"
done

get_disk_info | while read -r line; do
    print_colored_line "${line%=*}= " "${line#*=}"
done

exit 0