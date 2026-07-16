#!/bin/bash

# Импорт модулей
source ./config_loader.sh
source ./system_info.sh

# Настройка локали
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

# Загрузка конфигурации
load_config

# Получение цветов
title_bg=$(get_bg_color "$COL1_BG")
title_fg=$(get_text_color "$COL1_FG")
value_bg=$(get_bg_color "$COL2_BG")
value_fg=$(get_text_color "$COL2_FG")

# Сбор информации
collect_system_info

# Функция цветного вывода
print_colored() {
    local title="$1"
    local value="$2"
    echo -ne "\e[${title_bg};${title_fg}m${title}\e[0m"
    echo -e "\e[${value_bg};${value_fg}m${value}\e[0m"
}

# Вывод информации
echo "Системная информация:"
for line in "${SYSTEM_INFO[@]}"; do
    print_colored "${line%=*}= " "${line#*=}"
done

echo -e "\nСетевая информация:"
for line in "${NETWORK_INFO[@]}"; do
    print_colored "${line%=*}= " "${line#*=}"
done

echo -e "\nИнформация о памяти:"
for line in "${MEMORY_INFO[@]}"; do
    print_colored "${line%=*}= " "${line#*=}"
done

echo -e "\nИнформация о диске:"
for line in "${DISK_INFO[@]}"; do
    print_colored "${line%=*}= " "${line#*=}"
done

# Вывод цветовой схемы
print_color_scheme

exit 0