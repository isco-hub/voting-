#!/bin/bash
set -e

PORT="${PORT:-8080}"

sed -ri "s/^Listen 80$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "INFO: DB_CONNECTION=${DB_CONNECTION:-unset}, DB_URL set=$([ -n "${DB_URL:-}" ] && echo yes || echo no)"

php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

if [ -z "${APP_KEY:-}" ]; then
    APP_KEY="$(php artisan key:generate --show)"
    export APP_KEY
    echo "WARNING: APP_KEY was not set. Generated a temporary key for this instance."
fi

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
php artisan route:cache
php artisan view:cache

exec apache2-foreground
