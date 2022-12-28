#!/bin/bash
NAME="$(grep "CPRO_NAME" .env | sed -r 's/.{,10}//')"
if [ ! -f "laravel/app/Services/token_purchase.txt" ]; then
        touch laravel/app/Services/token_purchase.txt
fi
docker exec -it $NAME php artisan token:generate
