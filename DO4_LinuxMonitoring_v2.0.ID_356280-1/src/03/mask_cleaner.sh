#!/bin/bash

clean_by_mask() {
    local mask
    if [ "$#" -ge 1 ]; then
        mask="$1"
    else
        read -p "Enter name mask (e.g., _021121): " mask
    fi

    [ -z "$mask" ] && {
        echo "Mask cannot be empty"
        return 1
    }

    echo "Cleaning items with mask: *$mask*"
    
    # Удаление файлов
    for path in "${SEARCH_PATHS[@]}"; do
        find "$path" -type f -name "*${mask}*.log" -exec rm -fv {} +
    done
    
    # Удаление папок
    for path in "${SEARCH_PATHS[@]}"; do
        find "$path" -type d -name "*${mask}*" -exec rm -r fv {} +
    done
}