#!/bin/bash

# Подключаем конфигурацию
source "$(dirname "$0")/config.sh"

# Подключаем модули
source "$(dirname "$0")/sort_by_code.sh"
source "$(dirname "$0")/unique_ips.sh"
source "$(dirname "$0")/error_reqs.sh"
source "$(dirname "$0")/error_ips.sh"

# Проверка параметров
if [ $# -ne 1 ]; then
    echo "Использование: $0 <режим>"
    echo "Режимы:"
    echo "1 - Все записи, отсортированные по коду ответа"
    echo "2 - Все уникальные IP-адреса"
    echo "3 - Все запросы с ошибками (4xx или 5xx)"
    echo "4 - Уникальные IP-адреса с ошибочными запросами"
    exit 1
fi

# Выбор режима
case $1 in
    1) sort_by_code ;;
    2) unique_ips ;;
    3) error_requests ;;
    4) error_ips ;;
    *) 
        echo "Неверный режим. Допустимые значения: 1, 2, 3, 4"
        exit 1
        ;;
esac