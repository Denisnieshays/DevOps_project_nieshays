FROM alpine:3.14

# Все в одном RUN
RUN apk add --no-cache nginx curl && \
    addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -D appuser && \
    mkdir -p /var/www/html && \
    echo "<html><body><h1>My FastCGI App</h1><p>Working on port 81</p></body></html>" > /var/www/html/index.html && \
    echo 'events {} http { server { listen 81; root /var/www/html; index index.html; }}' > /etc/nginx/nginx.conf && \
    chown -R appuser:appuser /var/www/html

# HEALTHCHECK (порт 81)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:81/ || exit 1

EXPOSE 81

CMD ["nginx", "-g", "daemon off;"]