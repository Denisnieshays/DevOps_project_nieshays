#!/bin/bash

error_ips() {
    echo "Анализируем файл: $LOG_FILE"
    echo "Пример строки:"
    head -n 1 "$LOG_FILE"
    
    echo -e "\nУникальные IP с ошибками:"
    awk '
    {
        # Находим поле с кодом ответа (ищем 3-значное число)
        for(i=1; i<=NF; i++) {
            if($i ~ /^[0-9]{3}$/) {
                code = $i
                break
            }
        }
        
        # Если код начинается на 4 или 5
        if(code ~ /^4/ || code ~ /^5/) {
            print $1  # Выводим IP (первое поле)
        }
    }' "$LOG_FILE" | sort -u | tee debug_output.txt
    
    echo -e "\nПроверка:"
    echo "Все IP с ошибками:"
    grep -E ' (4|5)[0-9]{2} ' "$LOG_FILE" | awk '{print $1}'
    echo "Уникальные из них:"
    grep -E ' (4|5)[0-9]{2} ' "$LOG_FILE" | awk '{print $1}' | sort -u
}