FROM ubuntu:20.04
# Следующие аргументы приходят из docker-compose. они переопределяют локальные
ARG PHP_URL
# локальные аргументы
ARG TZ=Europe/Moscow
ARG	CSP_DIR_TMP=/tmp/csp
ARG	CADES_DIR_TMP=/tmp/cades
ARG	PHP_DIR=/opt/php
ARG	PHP_SRC=/tmp/php
ARG	PHP_PTH=/tmp/patch
ARG PDO_SRC=/opt/pdo
ARG CSP_INCLUDE=/opt/cprocsp/include
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ENV PATH="/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:${PATH}"

# Копирование исходников:
COPY sources/linux-amd64_deb.tgz $CSP_DIR_TMP/linux-amd64_deb.tgz
COPY sources/cades-linux-amd64.tar.gz $CADES_DIR_TMP/cades-linux-amd64.tar.gz
COPY sources/php7_support.patch $PHP_PTH/php7_support.patch
COPY sources/composer.phar /usr/local/bin/composer
# COPY sources/php-7.4.33.tar.gz $PHP_SRC

# Установка пакетов
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
	&& apt-get update && apt-get install --no-install-recommends -y \
	# libcurl4-openssl-dev \
    build-essential \
    ca-certificates \
    libsqlite3-dev \
    libboost-dev \
    libxml2-dev \
	libonig-dev \
	# supervisor \
    pkg-config \
    libzip-dev \
    libpq-dev \
	lsb-base \
	php-dev \
	openssl \
    unzip \
    wget \
	nano \
	gcc \
	zip \
	g++ \
# Установка csp
	&& mkdir -p $CSP_DIR_TMP && cd $CSP_DIR_TMP && \
	tar zxvf `ls -1` --strip-components=1 && \
	chmod +x install.sh && ./install.sh && \
	dpkg -i `ls -1 | grep lsb- | grep devel` && \
	cd && rm -rf $CSP_DIR_TMP && \
# Установка кадеса
	mkdir -p $CADES_DIR_TMP && cd $CADES_DIR_TMP && \
	tar zxvf `ls -1` --strip-components=1 && \
	dpkg -i `ls -1 |grep cades |grep .deb` && \
	dpkg -i `ls -1 |grep phpcades |grep .deb` && \
	cd && rm -rf $CADES_DIR_TMP && \
# Установка php
	mkdir $PHP_SRC && cd $PHP_SRC && wget $PHP_URL && \
	tar zxvf `ls -1` --strip-components=1 && \
	./configure --prefix $PHP_DIR \
        --enable-fpm \
        --enable-ftp \
        --enable-mbstring \
        --with-zip \
        --with-pgsql \
		# --with-curl \
        --with-openssl \
        --with-pdo-pgsql \
        --with-openssl-dir=/usr/bin && \
# Компилляция php с плагинами cryptopro
	cd $PHP_SRC && make && make install && update-alternatives \
	--install /usr/local/bin/php php $PHP_DIR/bin/php 100 && \
	cp $PHP_PTH/php7_support.patch /opt/cprocsp/src/phpcades/ && \
	cd /opt/cprocsp/src/phpcades/ && patch -p0 < ./php7_support.patch && \
	sed -i 's!PHPDIR=/php!PHPDIR=${PHP_SRC}!1' Makefile.unix && \
	sed -i 's!-fPIC -DPIC!-fPIC -DPIC -fpermissive!1' Makefile.unix && \
	sed -i 's!-lrdrsup -lcplib !-lrdrsup !1' Makefile.unix && \
	eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix && \
# Конфигурация php (ВАЖНО! 2 пробела для подключения libphpcades.so в php.ini)
	cp $PHP_SRC/php.ini-production $PHP_DIR/lib/php.ini && \
	export EXT_DIR=`php -ini |grep extension_dir | grep -v sqlite | awk '{print $3}'` && \
	ln -s /opt/cprocsp/src/phpcades/libphpcades.so $EXT_DIR/libphpcades.so && \
	sed -i '/; Dynamic Extensions ;/a extension=libphpcades.so'  $PHP_DIR/lib/php.ini && \
	mv $PHP_DIR/etc/php-fpm.conf.default $PHP_DIR/etc/php-fpm.conf && \
	sed -i 's!;error_log = log/php-fpm.log!error_log = syslog!g' $PHP_DIR/etc/php-fpm.conf && \
	mv $PHP_DIR/etc/php-fpm.d/www.conf.default $PHP_DIR/etc/php-fpm.d/www.conf && \
	sed -i 's!listen\s*=.*!listen = 9001!1' $PHP_DIR/etc/php-fpm.d/www.conf && \
	sed -i 's!nobody!www-data!g' $PHP_DIR/etc/php-fpm.d/www.conf && \
	chown -R www-data:www-data $PHP_DIR/var/log && \
	ln -s $PHP_DIR/sbin/php-fpm /usr/sbin/php-fpm && \
	rm -rf /tmp/*

# Конфигурация supervisor

# COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
# COPY supervisor/configs /etc/supervisor/conf.d

# Создание пользователя

# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
 	# && apt-get update \
    # && apt-get install -y sudo \
    # && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    # && chmod 0440 /etc/sudoers.d/$USERNAME

# Загрузка сертификата
COPY certificates /var/opt/cprocsp/keys/www-data/
RUN chown -R www-data:www-data /var/opt/cprocsp/keys/www-data/
USER www-data
RUN csptestf -absorb -certs
USER root
ARG ROOT_CA
ADD $ROOT_CA /root/test-ca-root.crt
RUN certmgr -inst -store mroot -file /root/test-ca-root.crt
	# && chmod 777 /var/log/supervisor/

# Открытие порта
EXPOSE 9001
# EXPOSE 6001
WORKDIR /var/www

# Запуск php-fpm
CMD ["php-fpm","-F"]
# ENTRYPOINT ["/usr/bin/supervisord"]
# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]