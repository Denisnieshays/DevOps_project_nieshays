#!/bin/bash

generate_name() {
    local chars="$1"
    local min_length=5
    local length=$(( RANDOM % (7 - min_length + 1) + min_length ))
    local name=""
    
    # Добавляем обязательные символы
    for (( i=0; i<${#chars}; i++ )); do
        name+="${chars:$i:1}"
    done
    
    # Дополняем до нужной длины
    while [ ${#name} -lt $length ]; do
        name+="${chars:$(( RANDOM % ${#chars} )):1}"
    done
    
    # Перемешиваем (сохраняя порядок обязательных символов)
    if [ ${#name} -gt ${#chars} ]; then
        local prefix="${name:0:${#chars}}"
        local suffix=$(echo "${name:${#chars}}" | fold -w1 | shuf | tr -d '\n')
        name="${prefix}${suffix}"
    fi
    
    echo "$name"
}