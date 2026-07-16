#!/bin/bash

# Глобальные переменные
declare -g folder_chars file_name_chars file_ext_chars file_size_mb
declare -g start_time start_datetime log_file current_date folder_date

validate_parameters() {
    [ "$#" -ne 3 ] && { echo "Ошибка: Необходимо 3 параметра"; exit 1; }

    folder_chars="$1"
    file_chars="$2"
    file_size_mb="${3%%Mb}"

    # Проверки параметров
    [ "${#folder_chars}" -gt 7 ] || [ "${#file_chars}" -gt 7 ] && { echo "Ошибка: Слишком длинные символы"; exit 1; }
    ! [[ "$file_size_mb" =~ ^[0-9]+$ ]] && { echo "Ошибка: Неверный размер файла"; exit 1; }
    [ "$file_size_mb" -gt 100 ] && { echo "Ошибка: Слишком большой файл"; exit 1; }

    IFS='.' read -ra file_parts <<< "$file_chars"
    file_name_chars="${file_parts[0]}"
    file_ext_chars="${file_parts[1]}"

    [ -z "$file_ext_chars" ] || [ "${#file_ext_chars}" -gt 3 ] && { echo "Ошибка: Неверное расширение"; exit 1; }
    [[ ! "$folder_chars" =~ ^[a-zA-Z]+$ ]] || [[ ! "$file_name_chars" =~ ^[a-zA-Z]+$ ]] || [[ ! "$file_ext_chars" =~ ^[a-zA-Z]+$ ]] && { echo "Ошибка: Недопустимые символы"; exit 1; }

    # Установка временных меток
    start_time=$(date +%s)
    start_datetime=$(date '+%Y-%m-%d %H:%M:%S')
    current_date=$(date +'%d%m%y')
    folder_date=$current_date
}