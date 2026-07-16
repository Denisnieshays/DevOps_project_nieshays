#!/bin/bash

error_requests() {
    echo "Запросы с ошибками (4xx или 5xx):"
    awk '
    {
        # Находим поле с кодом ответа (предпоследнее поле перед размером)
        for (i=NF; i>0; i--) {
            if ($i ~ /^[0-9]{3}$/) {
                code = $i
                break
            }
        }
        
        if (code ~ /^4/ || code ~ /^5/) {
            print $0
        }
    }' "$LOG_FILE"
}