FROM alpine:3.15
MAINTAINER Rakshit Menpara <rakshit@improwised.com>

ENV DOCKERIZE_VERSION v0.6.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

################## INSTALLATION STARTS ##################

# Install OS Dependencies
RUN set -ex \
  && apk add --no-cache --virtual .build-deps \
    autoconf automake build-base python gmp-dev \
    curl \
    nodejs nodejs-npm \
    tar \
  && apk add --no-cache --virtual .run-deps \
    # PHP and extensions
    php8 php8-bcmath php8-ctype php8-curl php8-dom php8-exif php8-fileinfo \
    php8-fpm php8-gd php8-gmp php8-iconv php8-intl php7-json php8-mbstring php7-mcrypt \
    php8-mysqlnd php8-mysqli php8-opcache php8-openssl php8-pcntl php8-pecl-apcu php8-pdo php8-pdo_mysql \
    php8-phar php8-posix php8-session php8-simplexml php8-sockets php8-sqlite3 php8-tidy \
    php8-tokenizer php8-xml php8-xmlreader php8-xmlwriter php8-zip php7-zlib php7-redis php8-soap php8-pdo_pgsql php8-pgsql \
    # Other dependencies
    mariadb-client sudo \
    # Miscellaneous packages
    bash ca-certificates dialog git libjpeg libpng-dev openssh-client supervisor vim wget \
    # Nginx
    nginx \
    # Create directories
  && mkdir -p /etc/nginx \
    && mkdir -p /run/nginx \
    && mkdir -p /etc/nginx/sites-available \
    && mkdir -p /etc/nginx/sites-enabled \
    && mkdir -p /var/log/supervisor \
    && rm -Rf /var/www/* \
    && rm -Rf /etc/nginx/nginx.conf \
  # Composer
  && wget https://composer.github.io/installer.sig -O - -q | tr -d '\n' > installer.sig \
    && php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === file_get_contents('installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php7 composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php7 -r "unlink('composer-setup.php'); unlink('installer.sig');" \
  # Cleanup
  && apk del .build-deps

##################  INSTALLATION ENDS  ##################

##################  CONFIGURATION STARTS  ##################

ADD rootfs /

RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
    ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini && \
    chown -R nginx:nginx /var/www

##################  CONFIGURATION ENDS  ##################

EXPOSE 443 80

WORKDIR /var/www

ENTRYPOINT ["dockerize", \
    "-template", "/etc/php7/php.ini:/etc/php7/php.ini", \
    "-template", "/etc/php7/php-fpm.conf:/etc/php7/php-fpm.conf", \
    "-template", "/etc/php7/php-fpm.d:/etc/php7/php-fpm.d", \
    "-template", "/google-auth.json.tmpl:/google-auth.json", \
    "-stdout", "/var/www/storage/logs/laravel.log", \
    "-stdout", "/var/log/nginx/error.log", \
    "-stdout", "/var/log/php7/error.log", \
    "-poll"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
