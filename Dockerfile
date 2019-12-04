FROM php:7.4-apache
LABEL maintainer="KYBERNA AG <info@kyberna.com>"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxml2 libxml2-dev libicu-dev \
    wget default-mysql-client unzip git postfix cron vim inetutils-syslogd libxrender1 libfontconfig1 \
    libapache2-mod-rpaf logrotate nano curl libmagickwand-dev libmagickcore-dev libzip-dev zip rsync

RUN docker-php-ext-install -j$(nproc) intl opcache pdo_mysql mysqli soap

RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install -j$(nproc) zip

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN pecl install apcu
RUN pecl install apcu_bc
RUN pecl install xdebug
RUN docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini
RUN docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

ADD apache2.conf /etc/apache2/apache2.conf
ADD logrotate-apache2 /etc/logrotate.d/apache2
ADD main.cf /etc/postfix/main.cf
ADD startup.sh /usr/local/startup.sh

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer
RUN curl -LO https://deployer.org/deployer.phar && mv deployer.phar /usr/local/bin/dep && chmod +x /usr/local/bin/dep
RUN a2enmod rewrite && a2enmod rpaf && a2enmod ssl && a2enmod headers && chmod +x /usr/local/startup.sh

EXPOSE 80 443

CMD "/usr/local/startup.sh"
