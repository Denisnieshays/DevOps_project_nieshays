#!/bin/bash

# Функция проверки свободного места
check_disk_space() {
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$free_space" -le 1 ]; then
        log_message "Критически мало свободного места (1GB или меньше). Прекращение работы."
        exit 1
    fi
}

# Создание папок и файлов
create_folders_and_files() {
    for (( i=1; i<=num_subdirs; i++ )); do
        check_disk_space
        
        # Генерируем уникальное имя папки
        folder_name=$(generate_name "$folder_chars")"_$current_date"
        mkdir -p "$path/$folder_name"
        log_message "Создана папка: $path/$folder_name"
        
        # Создаем файлы в папке
        for (( j=1; j<=num_files; j++ )); do
            check_disk_space
            
            # Генерируем уникальное имя файла и расширение
            file_name_part=$(generate_name "$file_name_chars")
            file_ext_part=$(generate_name "$file_ext_chars")
            
            # Убедимся, что расширение не длиннее 3 символов
            file_ext_part="${file_ext_part:0:3}"
            
            file_name="${file_name_part}_$current_date.${file_ext_part}"
            full_file_path="$path/$folder_name/$file_name"
            
            # Создаем файл заданного размера
            dd if=/dev/zero of="$full_file_path" bs=1K count=$file_size_kb 2>/dev/null
            
            log_message "  Создан файл: $full_file_path, Размер: ${file_size_kb}KB"
        done
    done
}