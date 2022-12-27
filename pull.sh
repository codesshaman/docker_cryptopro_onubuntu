#!/bin/bash
NAME="$(grep "PROJECT_NAME" .env | sed -r 's/.{,13}//')"
cd laravel
git pull
cd ..
docker exec -it $NAME composer update
docker exec -it $NAME php artisan passport:install
docker exec -it $NAME php artisan token:generate
docker exec -it $NAME php artisan optimize
docker exec -it $NAME php artisan optimize:clear