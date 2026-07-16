#!/bin/bash

get_disk_info() {
    local disk_info=$(df / -BM | awk 'NR==2')
    echo "SPACE_ROOT = $(echo "$disk_info" | awk '{printf "%.2f", $2/1}') МБ"
    echo "SPACE_ROOT_USED = $(echo "$disk_info" | awk '{printf "%.2f", $3/1}') МБ"
    echo "SPACE_ROOT_FREE = $(echo "$disk_info" | awk '{printf "%.2f", $4/1}') МБ"
}