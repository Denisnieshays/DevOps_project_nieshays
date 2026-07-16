#!/bin/bash

# Лог-файлы для поиска
LOG_PATTERNS=("creation_log_*.txt" "nginx_access_*.log" "$(pwd)")

# Шаблоны имен файлов/папок
FILE_PATTERN="*_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*"
DIR_PATTERN="*_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"

# Корневые директории для поиска
SEARCH_PATHS=("/tmp" "/var/tmp" "/home" "/data" "/mnt")