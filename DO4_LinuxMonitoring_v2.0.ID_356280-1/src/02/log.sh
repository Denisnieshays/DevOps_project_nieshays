#!/bin/bash

init_log_file() {
    log_file="creation_log_$(date +'%d%m%Y_%H%M%S').txt"
    echo "Лог создания файлов и папок" > "$log_file"
    echo "Дата начала: $start_datetime" >> "$log_file"
    echo "Параметры: $@" >> "$log_file"
    echo "" >> "$log_file"
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"
}

complete_log() {
    echo "" >> "$log_file"
    echo "Завершено: $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
    echo "Общее время выполнения: $(($(date +%s) - start_time)) секунд" >> "$log_file"
}