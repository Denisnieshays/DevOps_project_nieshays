#!/bin/bash

# Подключаем все необходимые модули
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/generate_names.sh"
source "$(dirname "$0")/create_entities.sh"
source "$(dirname "$0")/logging.sh"

# Основная функция
main() {
    # Проверяем параметры и конфигурацию
    validate_parameters "$@"
    
    # Инициализируем лог-файл
    init_log_file "$path"
    
    # Создаем папки и файлы
    create_folders_and_files
    
    # Завершаем лог
    complete_log
}

# Запускаем основную функцию
main "$@"