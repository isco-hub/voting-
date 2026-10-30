#!/bin/bash
set -e

PORT="${PORT:-8080}"

sed -ri "s/^Listen 80$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

php artisan config:clear
php artisan view:clear

attempt=0
until php artisan migrate --force; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 10 ]; then
        echo "Database migration failed after ${attempt} attempts."
        exit 1
    fi
    echo "Waiting for database... (${attempt}/10)"
    sleep 3
done

php artisan db:seed --force || true
php artisan storage:link || true

php artisan config:cache
php artisan view:cache

exec apache2-foreground
