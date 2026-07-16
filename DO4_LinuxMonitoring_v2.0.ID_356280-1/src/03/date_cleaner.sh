#!/bin/bash

clean_by_date() {
    # Получаем временной интервал
    if [ $# -ge 2 ]; then
        start_date="$1"
        end_date="$2"
    else
        read -p "Введите начальную дату и время (ГГГГ-ММ-ДД ЧЧ:ММ): " start_date
        read -p "Введите конечную дату и время (ГГГГ-ММ-ДД ЧЧ:ММ): " end_date
    fi

    # Проверка формата даты
    validate_date() {
        date -d "$1" &>/dev/null
        if [ $? -ne 0 ]; then
            echo "Ошибка: Некорректный формат даты '$1'. Используйте ГГГГ-ММ-ДД ЧЧ:ММ"
            return 1
        fi
        return 0
    }

    validate_date "$start_date" || return 1
    validate_date "$end_date" || return 1

    # Преобразуем в timestamp для проверки
    start_ts=$(date -d "$start_date" +%s)
    end_ts=$(date -d "$end_date" +%s)

    if [ "$start_ts" -gt "$end_ts" ]; then
        echo "Ошибка: Начальная дата должна быть раньше конечной"
        return 1
    fi

    # Шаблоны для поиска
    file_patterns=("*.log" "*.txt")
    dir_patterns=("*_????-??-??")

    # Поиск и удаление файлов
    deleted=0
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r -d $'\0' file; do
            file_ts=$(stat -c %Y "$file")
            if [ "$file_ts" -ge "$start_ts" ] && [ "$file_ts" -le "$end_ts" ]; then
                echo "Удаление файла: $file"
                rm -fv "$file"
                ((deleted++))
            fi
        done < <(find / -type f -name "$pattern" -print0 2>/dev/null)
    done

    # Поиск и удаление директорий
    for pattern in "${dir_patterns[@]}"; do
        while IFS= read -r -d $'\0' dir; do
            dir_ts=$(stat -c %Y "$dir")
            if [ "$dir_ts" -ge "$start_ts" ] && [ "$dir_ts" -le "$end_ts" ]; then
                echo "Удаление директории: $dir"
                rm -r fv "$dir"
                ((deleted++))
            fi
        done < <(find / -type d -name "$pattern" -print0 2>/dev/null)
    done

    if [ "$deleted" -eq 0 ]; then
        echo "Файлы для удаления не найдены"
    else
        echo "Удалено объектов: $deleted"
    fi
}