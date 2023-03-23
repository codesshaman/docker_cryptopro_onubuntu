#!/bin/bash
NAME="$(grep "CPRO_NAME" .env | sed -r 's/.{,10}//')"
docker exec -it --user root $NAME bash