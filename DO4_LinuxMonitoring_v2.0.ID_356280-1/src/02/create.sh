#!/bin/bash

create_folders_and_files() {
    local created_folders=0
    local possible_paths=("/tmp" "/var/tmp" "/home" "/data" "/mnt")
    
    while [ $created_folders -lt 100 ]; do
        check_disk_space || break
        
        local folder_name=$(generate_name "$folder_chars")"_$folder_date"
        is_valid_folder "$folder_name" || continue
        
        local base_path="${possible_paths[$RANDOM % ${#possible_paths[@]}]}"
        local full_folder_path="$base_path/$folder_name"
        
        mkdir -p "$full_folder_path"
        log_message "Создана папка: $full_folder_path"
        ((created_folders++))
        
        create_files "$full_folder_path" || break
    done
}

create_files() {
    local folder_path="$1"
    local num_files=$(( RANDOM % 10 + 1 ))
    
    for (( j=1; j<=num_files; j++ )); do
        check_disk_space || return 1
        
        local file_name_part=$(generate_name "$file_name_chars")
        local file_ext_part=$(generate_name "$file_ext_chars")
        file_ext_part="${file_ext_part:0:3}"
        
        local file_name="${file_name_part}_$folder_date.${file_ext_part}"
        local full_file_path="$folder_path/$file_name"
        
        dd if=/dev/zero of="$full_file_path" bs=1M count=$file_size_mb 2>/dev/null
        log_message "Создан файл: $full_file_path, Размер: ${file_size_mb}MB"
    done
}