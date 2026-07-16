#!/bin/bash

# Глобальные переменные
declare -g path num_subdirs folder_chars num_files file_name_chars file_ext_chars file_size_kb current_date log_file

validate_parameters() {
    # Проверка количества параметров
    if [ "$#" -ne 6 ]; then
        echo "Ошибка: Скрипт должен быть запущен с 6 параметрами."
        echo "Пример: main.sh /opt/test 4 az 5 az.az 3kb"
        exit 1
    fi

    # Парсинг параметров
    path="$1"
    num_subdirs="$2"
    folder_chars="$3"
    num_files="$4"
    file_chars="$5"
    file_size_kb="${6%%kb}" # Удаляем 'kb' из параметра размера

    # Проверка параметров
    if [ ! -d "$path" ]; then
        echo "Ошибка: Указанный путь не существует или не является директорией."
        exit 1
    fi

    if ! [[ "$num_subdirs" =~ ^[0-9]+$ ]] || ! [[ "$num_files" =~ ^[0-9]+$ ]] || ! [[ "$file_size_kb" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: Количество папок, файлов и размер файла должны быть числами."
        exit 1
    fi

    if [ "${#folder_chars}" -gt 7 ] || [ "${#file_chars}" -gt 7 ]; then
        echo "Ошибка: Длина строки символов для папок и файлов не должна превышать 7 символов."
        exit 1
    fi

    if [ "$file_size_kb" -gt 100 ]; then
        echo "Ошибка: Размер файла не должен превышать 100KB."
        exit 1
    fi

    # Разделение символов для имени файла и расширения
    IFS='.' read -ra file_parts <<< "$file_chars"
    file_name_chars="${file_parts[0]}"
    file_ext_chars="${file_parts[1]}"

    if [ -z "$file_ext_chars" ] || [ "${#file_ext_chars}" -gt 3 ]; then
        echo "Ошибка: Расширение файла должно быть от 1 до 3 символов."
        exit 1
    fi

    # Проверка, что символы только буквы английского алфавита
    if [[ ! "$folder_chars" =~ ^[a-zA-Z]+$ ]] || [[ ! "$file_name_chars" =~ ^[a-zA-Z]+$ ]] || [[ ! "$file_ext_chars" =~ ^[a-zA-Z]+$ ]]; then
        echo "Ошибка: Символы должны быть только буквами английского алфавита."
        exit 1
    fi

    current_date=$(date +'%d%m%Y')
}