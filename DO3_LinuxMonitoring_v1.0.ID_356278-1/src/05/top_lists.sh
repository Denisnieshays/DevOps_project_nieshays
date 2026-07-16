#!/bin/bash

dir_path=$1

# Топ-5 папок
echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
du -h "$dir_path" | sort -hr | head -n 6 | tail -n 5 | awk '{print NR " - " $2 ", " $1}'

# Топ-10 файлов
echo -e "\nTOP 10 files of maximum size arranged in descending order (path, size and type):"
find "$dir_path" -type f -exec du -h {} + | sort -hr | head -n 10 | awk '{print NR " - " $2 ", " $1}' | while read -r line; do
    file_path=$(echo "$line" | awk -F', ' '{print $1}' | sed 's/^[0-9]\+ - //')
    size=$(echo "$line" | awk -F', ' '{print $2}')
    file_type=$(file -b "$file_path" | awk '{print $1}')
    echo "${line}, $file_type"
done

# Топ-10 исполняемых файлов
echo -e "\nTOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
find "$dir_path" -type f -executable -exec du -h {} + | sort -hr | head -n 10 | awk '{print NR " - " $2 ", " $1}' | while read -r line; do
    file_path=$(echo "$line" | awk -F', ' '{print $1}' | sed 's/^[0-9]\+ - //')
    size=$(echo "$line" | awk -F', ' '{print $2}')
    hash=$(md5sum "$file_path" | awk '{print $1}')
    echo "${line}, $hash"
done