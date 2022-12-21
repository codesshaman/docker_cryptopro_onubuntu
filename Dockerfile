FROM ubuntu:20.04
# Следующие аргументы приходят из docker-compose. они переопределяют локальные
ARG TEST_CA_DIR
ARG COMPOSER
# локальные аргументы
ARG TZ=Europe/Moscow
ARG     CSP_DIR_TMP=/tmp/csp
ARG     CADES_DIR_TMP=/tmp/cades
ARG     PHP_DIR=/opt/php
ARG     PHP_SRC=/tmp/php
ARG     PHP_PTH=/tmp/patch
ARG PDO_SRC=/opt/pdo
ARG CSP_INCLUDE=/opt/cprocsp/include
ENV PATH="/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:${PATH}"

# Установка пакетов
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && apt-get update \
        && apt-get install --no-install-recommends -y \
                libcurl4-openssl-dev \
                ca-certificates \
                build-essential \
                libsqlite3-dev \
                libboost-dev \
                libxml2-dev \
                libonig-dev \
                libzip-dev \
                pkg-config \
                libpq-dev \
                lsb-base \
                php-dev \
                openssl \
                unzip \
                wget \
                curl \
                nano \
                gcc \
                zip \
                g++ && \
        mkdir $PHP_SRC

# Копирование исходников:
COPY sources/linux-amd64_deb.tgz $CSP_DIR_TMP/linux-amd64_deb.tgz
COPY sources/cades-linux-amd64.tar.gz $CADES_DIR_TMP/cades-linux-amd64.tar.gz
COPY sources/php7_support.patch $PHP_PTH/php7_support.patch
COPY $COMPOSER /usr/local/bin/composer
COPY sources/php-7.4.3.tar.gz $PHP_SRC

# Установка csp
RUN mkdir -p $CSP_DIR_TMP && cd $CSP_DIR_TMP && \
        tar zxvf `ls -1` --strip-components=1 && \
        chmod +x install.sh && ./install.sh && \
        dpkg -i `ls -1 | grep lsb- | grep devel` && \
        cd && rm -rf $CSP_DIR_TMP

# Установка кадеса
RUN     mkdir -p $CADES_DIR_TMP && cd $CADES_DIR_TMP && \
        tar zxvf `ls -1` --strip-components=1 && \
        dpkg -i `ls -1 |grep cades |grep .deb` && \
        dpkg -i `ls -1 |grep phpcades |grep .deb` && \
        cd && rm -rf $CADES_DIR_TMP

# Установка php
RUN cd $PHP_SRC && tar zxvf php-7.4.3.tar.gz && mv php-7.4.3/* . &&  \
        ./configure --prefix \
        $PHP_DIR \
        --enable-fpm \
        --enable-ftp \
        --enable-mbstring \
        --with-zip \
        --with-pgsql \
        --with-openssl \
        --with-pdo-pgsql \
        --with-openssl-dir=/usr/bin \
        --with-curl=/opt/cprocsp/include/curl && \
        make && make install && update-alternatives --install /usr/local/bin/php php $PHP_DIR/bin/php 100 && \
        cp $PHP_PTH/php7_support.patch /opt/cprocsp/src/phpcades/ && \
        cd /opt/cprocsp/src/phpcades/ && patch -p0 < ./php7_support.patch && \
        sed -i 's!PHPDIR=/php!PHPDIR=${PHP_SRC}!1' Makefile.unix && \
        sed -i 's!-fPIC -DPIC!-fPIC -DPIC -fpermissive!1' Makefile.unix && \
        sed -i 's!-lrdrsup -lcplib !-lrdrsup !1' Makefile.unix && \
        eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix

# # Конфигурация php (ВАЖНО! 2 пробела для подключения libphpcades.so в php.ini)
RUN cp $PHP_SRC/php.ini-production $PHP_DIR/lib/php.ini && \
        export EXT_DIR=`php -ini |grep extension_dir | grep -v sqlite | awk '{print $3}'` && \
        ln -s /opt/cprocsp/src/phpcades/libphpcades.so $EXT_DIR/libphpcades.so && \
        sed -i '/; Dynamic Extensions ;/a extension=libphpcades.so'  $PHP_DIR/lib/php.ini && \
        sed -i 's!upload_max_filesize = 2M!upload_max_filesize = 1000M!g'  $PHP_DIR/lib/php.ini && \
        sed -i 's!post_max_size = 8M!post_max_size = 1000M!g'  $PHP_DIR/lib/php.ini && \
        sed -i 's!max_execution_time = 30!max_execution_time = 3000!g'  $PHP_DIR/lib/php.ini && \
        sed -i 's!max_file_uploads = 20!max_file_uploads = 1000!g'  $PHP_DIR/lib/php.ini && \
        sed -i 's!max_input_time = 60!max_input_time = 6000!g'  $PHP_DIR/lib/php.ini && \
        sed -i 's!memory_limit = 128M!memory_limit = 1024M!g'  $PHP_DIR/lib/php.ini && \
        mv $PHP_DIR/etc/php-fpm.conf.default $PHP_DIR/etc/php-fpm.conf && \
        sed -i 's!;error_log = log/php-fpm.log!error_log = syslog!g' $PHP_DIR/etc/php-fpm.conf && \
        mv $PHP_DIR/etc/php-fpm.d/www.conf.default $PHP_DIR/etc/php-fpm.d/www.conf && \
        sed -i 's!listen\s*=.*!listen = 9000!1' $PHP_DIR/etc/php-fpm.d/www.conf && \
        sed -i 's!nobody!www-data!g' $PHP_DIR/etc/php-fpm.d/www.conf && \
        chown -R www-data:www-data $PHP_DIR/var/log && rm -rf /tmp/* && \
        ln -s $PHP_DIR/sbin/php-fpm /usr/sbin/php-fpm && \
        apt-get purge -y --allow-remove-essential  \
                build-essential \
                libsqlite3-dev \
                libboost-dev \
                libxml2-dev \
                libonig-dev \
                libzip-dev \
                pkg-config \
                libpq-dev \
                php-dev \
                openssl \
                unzip \
                gcc \
                zip \
                g++

# Загрузка сертификата
COPY certificates /var/opt/cprocsp/keys/www-data/
RUN chown -R www-data:www-data /var/opt/cprocsp/keys/www-data/
USER www-data
RUN csptestf -absorb -certs
USER root
ADD $TEST_CA_DIR /root/test-ca-root.crt
RUN certmgr -inst -store mroot -file /root/test-ca-root.crt

# Открытие порта
EXPOSE 9000
WORKDIR /var/www

# Запуск php-fpm
CMD ["php-fpm","-F"]
