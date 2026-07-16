#!/bin/bash

dir_path=$1

# Статистика по папкам
folder_count=$(find "$dir_path" -type d | wc -l)
echo "Total number of folders (including all nested ones) = $((folder_count - 1))"

# Статистика по файлам
file_count=$(find "$dir_path" -type f | wc -l)
echo "Total number of files = $file_count"

conf_count=$(find "$dir_path" -type f -name "*.conf" | wc -l)
txt_count=$(find "$dir_path" -type f -exec file {} \; | grep -c "text")
exe_count=$(find "$dir_path" -type f -executable | wc -l)
log_count=$(find "$dir_path" -type f -name "*.log" | wc -l)
archive_count=$(find "$dir_path" -type f \( -name "*.zip" -o -name "*.tar" -o -name "*.gz" -o -name "*.bz2" -o -name "*.rar" -o -name "*.7z" \) | wc -l)
link_count=$(find "$dir_path" -type l | wc -l)

echo "Number of:"
echo "Configuration files (with the .conf extension) = $conf_count"
echo "Text files = $txt_count"
echo "Executable files = $exe_count"
echo "Log files (with the extension .log) = $log_count"
echo "Archive files = $archive_count"
echo "Symbolic links = $link_count"