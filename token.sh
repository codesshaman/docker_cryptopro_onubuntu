#!/bin/bash
NAME="$(grep "PROJECT_NAME" .env | sed -r 's/.{,13}//')"
if [ ! -f "laravel/app/Services/token_purchase.txt" ]; then
        touch laravel/app/Services/token_purchase.txt
fi
docker exec -it $NAME php artisan token:generate
