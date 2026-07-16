#!/bin/bash

sort_by_code() {
    echo "Сортировка логов по коду ответа:"
    
    # Обрабатываем файл и сортируем
    awk '
    {
        # Ищем код ответа - трёхзначное число после HTTP/1.1"
        if (match($0, /HTTP\/1\.1" ([0-9]{3})/, m)) {
            code = m[1]
            print code, $0
        }
    }' "$LOG_FILE" | sort -n | cut -d' ' -f2-
    
}