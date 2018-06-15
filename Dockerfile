FROM php:5.6-apache
LABEL maintainer="KYBERNA AG <info@kyberna.com>"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxml2 libxml2-dev libicu-dev \
    wget mysql-client unzip git postfix cron vim pdftk inetutils-syslogd libxrender1 libfontconfig1 \
    libapache2-mod-rpaf logrotate

RUN docker-php-ext-install -j$(nproc) iconv intl mcrypt opcache pdo pdo_mysql mysqli mysql mbstring soap xml zip
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

RUN pecl install xdebug-2.5.5

ADD apache2.conf /etc/apache2/apache2.conf
ADD logrotate-apache2 /etc/logrotate.d/apache2
ADD main.cf /etc/postfix/main.cf
ADD startup.sh /usr/local/startup.sh

RUN a2enmod rewrite && a2enmod rpaf && a2enmod ssl && mkdir /composer-setup && wget https://getcomposer.org/installer -P /composer-setup && php /composer-setup/installer --install-dir=/usr/bin && rm -Rf /composer-setup && curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony && chmod +x /usr/local/startup.sh

EXPOSE 80 443

CMD "/usr/local/startup.sh"
