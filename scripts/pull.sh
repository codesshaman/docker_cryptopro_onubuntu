#!/bin/bash
NAME="$(grep "CPRO_NAME" .env | sed -r 's/.{,10}//')"
cd laravel
git pull
cd ..
docker exec -it $NAME composer update --ignore-platform-req=ext-curl
#docker exec -it $NAME php artisan passport:install
#docker exec -it $NAME php artisan token:generate
docker exec -it $NAME php artisan optimize
#docker exec -it $NAME php artisan optimize:clear
