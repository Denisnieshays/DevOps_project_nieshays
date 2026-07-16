#!/bin/bash

# Подключаем модули
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/names.sh"
source "$(dirname "$0")/check.sh"
source "$(dirname "$0")/create.sh"
source "$(dirname "$0")/log.sh"

# Основная функция
main() {
    validate_parameters "$@"
    init_log_file
    create_folders_and_files
    complete_log
    
    echo "Скрипт завершен."
    echo "Время начала: $start_datetime"
    echo "Время окончания: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Общее время выполнения: $(($(date +%s) - start_time)) секунд"
    echo "Лог сохранен в: $log_file"
}

main "$@"