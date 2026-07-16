#!/bin/bash

validate_date() {
    date -d "$1" >/dev/null 2>&1
    return $?
}

check_root() {
    [ "$EUID" -eq 0 ] || {
        echo "This operation requires root privileges"
        exit 1
    }
}