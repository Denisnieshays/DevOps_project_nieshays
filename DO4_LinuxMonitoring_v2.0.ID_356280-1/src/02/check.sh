#!/bin/bash

check_disk_space() {
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    [ "$free_space" -le 1 ] && { log_message "Мало места (1GB)"; return 1; }
    return 0
}

is_valid_folder() {
    [[ "$1" == *"bin"* ]] || [[ "$1" == *"sbin"* ]] && return 1
    return 0
}