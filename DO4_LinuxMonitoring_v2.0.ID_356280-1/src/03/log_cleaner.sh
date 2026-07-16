#!/bin/bash

clean_by_log() {
    # 1. Поиск лог-файлов в стандартных местах
    local log_dirs=("/var/log" "/tmp" "$(pwd)")
    local log_files=()
    
    echo "Ищем лог-файлы в следующих директориях:"
    for dir in "${log_dirs[@]}"; do
        echo " - $dir"
        while IFS= read -r -d $'\0' file; do
            log_files+=("$file")
        done < <(find "$dir" -name "creation_log_*.txt" -print0 2>/dev/null)
    done

    # 2. Проверка найденных файлов
    if [ ${#log_files[@]} -eq 0 ]; then
        echo "Лог-файлы не найдены ни в одной из проверенных директорий"
        echo "Рекомендуемые места для размещения: /var/log/ или /tmp/"
        return 1
    fi

    # 3. Выбор самого свежего лог-файла
    local latest_log=$(ls -t "${log_files[@]}" | head -1)
    echo "Выбран лог-файл: $latest_log"

    # 4. Извлечение путей для удаления
    local files_to_remove=()
    if grep -q "Создан" "$latest_log"; then
        files_to_remove=($(grep -oP 'Создан (файл|папка): \K[^,]+' "$latest_log"))
    else
        echo "Формат лог-файла не распознан"
        return 1
    fi

    [ ${#files_to_remove[@]} -eq 0 ] && {
        echo "Не найдено файлов для удаления в лог-файле"
        return 1
    }

    # 5. Подтверждение и удаление
    echo "Найдено ${#files_to_remove[@]} объектов для удаления"
    printf "%s\n" "${files_to_remove[@]}" | head -5
    [ ${#files_to_remove[@]} -gt 5 ] && echo "... (и ещё $((${#files_to_remove[@]}-5))"

    read -p "Продолжить удаление? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || return 0

    # 6. Процесс удаления
    for item in "${files_to_remove[@]}"; do
        if [ -e "$item" ]; then
            if [ -d "$item" ]; then
                rm -rfv "$item"
            else
                rm -fv "$item"
            fi
        else
            echo "Не найден: $item"
        fi
    done

    # 7. Удаление лог-файла
    read -p "Удалить сам лог-файл ($latest_log)? [y/N] " log_confirm
    [[ "$log_confirm" =~ ^[Yy]$ ]] && rm -v "$latest_log"
}