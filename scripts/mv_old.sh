#!/bin/bash
rm -rf laravel_old
mv laravel laravel_old
make down
make build