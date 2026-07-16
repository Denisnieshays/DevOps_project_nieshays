FROM alpine:3.14

RUN apk add --no-cache nginx curl && \
    addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -D appuser && \
    mkdir -p /var/www/html && \
    echo "Hello, World!" > /var/www/html/index.html && \
    echo 'events {} http { server { listen 80; root /var/www/html; index index.html; }}' > /etc/nginx/nginx.conf && \
    chown -R appuser:appuser /var/www/html && \
    echo "security-check" > /home/appuser/security-pass.txt

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

USER appuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]