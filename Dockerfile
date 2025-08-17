# --- System Stage: Install all system tools and extensions ---
FROM php:8.4-fpm-trixie AS system

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Install system dependencies (both build and runtime)
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libpq-dev \
    libsqlite3-dev \
    libgmp-dev \
    libmemcached-dev \
    libssl-dev \
    libsodium-dev \
    unzip \
    curl \
    wget \
    git \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
# Note: ffi, ctype, dom, fileinfo, iconv are core extensions in PHP 8.4
ENV PHP_EXT="pdo pdo_mysql pdo_pgsql pdo_sqlite mysqli pgsql zip intl mbstring bcmath calendar gd gettext gmp exif soap sockets xsl opcache pcntl"
RUN docker-php-ext-install $PHP_EXT

# Install PECL extensions
ENV PHP_PKGS="redis memcached igbinary msgpack swoole grpc protobuf opentelemetry"
RUN pecl install $PHP_PKGS && docker-php-ext-enable $PHP_PKGS

# Configure PHP settings for production
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.save_comments=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/opcache.ini

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
