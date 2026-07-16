# Используем минимальный образ Alpine
FROM alpine:3.14

# ВСЁ в одной инструкции RUN: установка пакетов + создание папок
RUN apk update && apk add --no-cache \
    nginx \
    spawn-fcgi \
    gcc \
    libc-dev \
    fcgi-dev \
    && mkdir -p /app /run/nginx

# Вторая инструкция RUN: компиляция + копирование конфига
WORKDIR /app
COPY server.c .
COPY nginx.conf .
RUN gcc server.c -o server -lfcgi \
    && cp nginx.conf /etc/nginx/nginx.conf \
    && rm server.c nginx.conf

EXPOSE 80

# Запускаем сервисы
CMD nginx && spawn-fcgi -p 8080 -n /app/server && sleep infinity