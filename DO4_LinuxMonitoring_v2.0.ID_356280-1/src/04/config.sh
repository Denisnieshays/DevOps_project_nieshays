#!/bin/bash

# Коды ответов HTTP и их значения:
declare -A HTTP_CODES=(
    [200]="OK: Успешный запрос"
    [201]="Created: Ресурс успешно создан"
    [400]="Bad Request: Неверный синтаксис запроса"
    [401]="Unauthorized: Требуется аутентификация"
    [403]="Forbidden: Доступ запрещен"
    [404]="Not Found: Ресурс не найден"
    [500]="Internal Server Error: Внутренняя ошибка сервера"
    [501]="Not Implemented: Метод не поддерживается"
    [502]="Bad Gateway: Ошибка шлюза"
    [503]="Service Unavailable: Сервис недоступен"
)

# Другие конфигурационные параметры
declare -a HTTP_METHODS=("GET" "POST" "PUT" "PATCH" "DELETE")
declare -a URL_PATHS=("/" "/index.html" "/about" "/contact" "/products" "/services" "/blog" "/images/photo.jpg" "/static/style.css" "/api/data")
declare -a USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
    "Google Chrome/91.0.4472.124"
    "Opera/9.80 (Windows NT 6.1; WOW64)"
    "Safari/537.36"
    "Internet Explorer/11.0"
    "Microsoft Edge/91.0.864.59"
    "Mozilla/5.0 (compatible; Googlebot/2.1)"
    "Mozilla/5.0 (compatible; Bingbot/2.0)"
    "curl/7.68.0"
    "Wget/1.21.1"
)