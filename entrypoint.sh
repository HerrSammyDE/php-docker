#!/bin/sh
set -e

# Führe die folgenden Befehle aus, wenn das erste Argument "php-fpm" oder "php" ist
if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ]; then
  # Cache everything
  php artisan optimize
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan event:cache
fi

# Starte die erforderlichen Dienste im Hintergrund
exec "$@" &
exec nginx &
exec crond -f
