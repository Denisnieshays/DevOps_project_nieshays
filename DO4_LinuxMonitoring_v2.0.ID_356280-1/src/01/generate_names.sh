#!/bin/bash

generate_name() {
    local chars="$1"
    local min_length=4
    local length=$(( RANDOM % (7 - min_length + 1) + min_length ))
    local name=""

    # Обязательные уникальные символы (в порядке параметра)
    for (( i=0; i<${#chars}; i++ )); do
        name="${name}${chars:$i:1}"
    done

    # Добавляем случайные символы из диапазона, пока не достигнем длины
    while [ ${#name} -lt $length ]; do
        random_char="${chars:$(( RANDOM % ${#chars} )):1}"
        name="${name}${random_char}"
    done

    # Перемешиваем часть имени после обязательных символов
    if [ ${#name} -gt ${#chars} ]; then
        local prefix="${name:0:${#chars}}"
        local suffix="${name:${#chars}}"
        suffix=$(echo "$suffix" | fold -w1 | shuf | tr -d '\n')
        name="${prefix}${suffix}"
    fi

    echo "$name"
}