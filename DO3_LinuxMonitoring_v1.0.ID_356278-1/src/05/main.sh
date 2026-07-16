#!/bin/bash

# Проверка аргументов
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path/>"
    exit 1
fi

if [[ ! "$1" =~ /$ ]]; then
    echo "Error: Directory path must end with '/'"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: Directory $1 does not exist"
    exit 1
fi

start_time=$(date +%s.%N)
dir_path=$1

# Вызов подскриптов
./stats.sh "$dir_path"       # Общая статистика (папки + файлы)
./top_lists.sh "$dir_path"   # Топ-5 папок, топ-10 файлов и исполняемых файлов

end_time=$(date +%s.%N)
elapsed=$(echo "$end_time - $start_time" | bc)
echo "Script execution time (in seconds) = $elapsed"