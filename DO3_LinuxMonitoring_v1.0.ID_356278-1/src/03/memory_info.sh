#!/bin/bash

get_memory_info() {
    local mem_info=$(free -m | awk '/Mem:/')
    echo "ОБЩИЙ ОБЪЕМ ОЗУ = $(echo "$mem_info" | awk '{printf "%.3f", $2/1024}') ГБ"
    echo "RAM_USED = $(echo "$mem_info" | awk '{printf "%.3f", $3/1024}') ГБ"
    echo "RAM_FREE = $(echo "$mem_info" | awk '{printf "%.3f", $4/1024}') ГБ"
}