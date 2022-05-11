FROM php:7.4-apache

RUN apt-get update && apt-get install -y libjpeg62-turbo-dev \
    apt-transport-https \
    libfreetype6-dev \
    libmcrypt-dev \
    libssl-dev \
    vim \
    zip \
    unzip \
    libcurl4-openssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype-dev \
    libxslt-dev \
    libzip-dev \
    libgd-dev \
    && docker-php-ext-install bcmath \
    intl \
    pdo_mysql \
    soap \
    sockets \
    xmlwriter \
    xsl \
    zip \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) gd

RUN a2enmod rewrite headers

COPY build/config/php.ini /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini

COPY build/config/apache2.conf /etc/apache2/apache2.conf

COPY build/config/magento2.conf /etc/apache2/sites-available/magento2.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer