# Wähle das PHP-Image mit der gewünschten Version
FROM php:8.0-fpm

# Aktualisiere die Paketliste und installiere Abhängigkeiten
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nano \
    unzip \
    nginx \
    cron \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    libgmp-dev \
    libxslt1-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libexif-dev \
    libwebp-dev \
    libjpeg-dev \
    libpcre3-dev \
    libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installiere die PHP-Erweiterungen
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) mbstring \
    && docker-php-ext-install -j$(nproc) xml \
    && docker-php-ext-install -j$(nproc) curl \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-install -j$(nproc) calendar \
    && docker-php-ext-install -j$(nproc) gmp \
    && pecl install redis \
    && docker-php-ext-enable redis

# Installiere Supervisor
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/*

# Füge den Laravel-Cronjob hinzu
RUN (crontab -l -u www-data 2>/dev/null; echo "* * * * * php /var/www/artisan schedule:run >/dev/null 2>&1") | crontab -u www-data -

# Setze das Arbeitsverzeichnis
WORKDIR /var/www

# Verschiebe die Produktionsversion der php.ini-Datei
#RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Kopiere die benutzerdefinierte entrypoint.sh und setze die Ausführungsrechte
COPY ./entrypoint.sh /usr/local/bin/php-entrypoint
RUN chmod +x /usr/local/bin/php-entrypoint

# Kopiere die benutzerdefinierte PHP-FPM-Konfigurationsdatei
#COPY ./web/www.conf /usr/local/etc/php-fpm.d/www.conf

# Kopiere die benutzerdefinierten Konfigurationsdateien
#ADD web/nginx.conf /etc/nginx/nginx.conf
#COPY web/sites/* /etc/nginx/conf.d/
#COPY ./web/php.ini /usr/local/etc/php/php.ini

# Füge die EXPOSE-Anweisung hinzu
EXPOSE 80

# Füge die ENTRYPOINT und CMD-Anweisungen hinzu
ENTRYPOINT ["php-entrypoint"]
CMD ["php-fpm", "-R"]
