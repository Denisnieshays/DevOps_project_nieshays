#!/bin/bash

# Подключаем модули
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/log_cleaner.sh"
source "$(dirname "$0")/date_cleaner.sh"
source "$(dirname "$0")/mask_cleaner.sh"

# Проверка параметров
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 {1|2|3} [args...]"
    echo "1 - Clean by log file"
    echo "2 - Clean by creation date"
    echo "3 - Clean by name mask"
    exit 1
fi

METHOD=$1
shift

case $METHOD in
    1) clean_by_log "$@" ;;
    2) clean_by_date "$@" ;;
    3) clean_by_mask "$@" ;;
    *) echo "Invalid method"; exit 1 ;;
esac

echo "Cleaning completed"