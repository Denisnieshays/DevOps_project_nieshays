#!/bin/bash

save_to_file() {
    local filename=$(date +"%d_%m_%y_%H_%M_%S").status
    {
        get_system_info
        get_network_info
        get_memory_info
        get_disk_info
    } > "$filename"
    echo "Данные сохранены в файл: $filename"
}

ask_to_save() {
    read -p "Сохранить данные в файл? (Y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        save_to_file
    else
        echo "Данные не сохранены."
    fi
}