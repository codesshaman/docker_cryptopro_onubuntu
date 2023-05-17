#!/bin/bash
NAME="$(grep "CPRO_NAME" .env | sed -r 's/.{,10}//')"
PORT="$(grep "WEBSOCKET_PORT" .env | sed -r 's/.{,15}//')"
docker exec -it $NAME php artisan websockets:serve --port=$PORT