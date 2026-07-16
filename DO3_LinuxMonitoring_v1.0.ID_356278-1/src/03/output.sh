#!/bin/bash

print_colored_line() {
    local title="$1"
    local value="$2"
    echo -ne "\e[${title_bg};${title_fg}m${title}\e[0m"
    echo -e "\e[${value_bg};${value_fg}m${value}\e[0m"
}