#!/bin/bash
# Необходимые переменные
mypath=${PWD}
no='\033[0m'
ok='\033[0;32m'
warn='\033[33;01m'
error='\033[31;01m'
repos=($(cat sources/repos.txt))
network=($(cat sources/network.txt))
branch=($(cat sources/branch.txt))
arr=($(echo "${mypath}" | tr '.' '\n'))
arr=($(echo "${arr}" | tr '/' '\n'))
prefix="${arr[-1]}"
cproport=8090
wsport=6001
timeout=1
# Функция подтверждения
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}
# Проверка существования файла .env
if [ ! -f .env ]; then
    # Проверка существования файлов с переменными
    if [ ! -f sources/branch.txt ]; then
        echo "Файл с именем ветки отсутствует"
        echo "Сохраните имя вашей ветки git в файле с именем nameofbranch.txt в корне проекта"
        exit
    fi
    if [ ! -f sources/network.txt ]; then
        echo "Файл с именем сети отсутствует"
        echo "Сохраните имя вашей сети docker в файл network.txt в корне проекта"
        exit
    fi
    if [ ! -f sources/repos.txt ]; then
        echo "Файл с именем репозитория отсутствует"
        echo "Сохраните адрес репозитория в файл repos.txt в корне проекта"
        exit
    fi
    # Обработка порта 6001
    if docker ps --format "{{.Ports}}" | grep 6001/tcp; then
        echo "Порт 6001 уже используется!"
        if confirm "Сменить порт для вебсокета? (y/n or enter for no)"; then
            echo "Вывожу список используемых портов:"
            docker ps --format "{{.Ports}}"
            echo "Введите номер порта для вебсокета:"
            read wsport
        else
            echo "Останавливаю сборку"
            exit
        fi
    fi
    # Обработка порта 8090
    if docker ps --format "{{.Ports}}" | grep 8090; then
        echo "Порт 8090 уже используется!"
        if confirm "Сменить порт для laravel? (y/n or enter for no)"; then
            echo "Вывожу список используемых портов:"
            docker ps --format "{{.Ports}}"
            echo "Введите номер порта для laravel:"
            read cproport
        else
            echo "Останавливаю сборку"
            exit
        fi
    fi
    # Создание нового .env-файла
    cp .env.example .env
    sed -i "s!WEBSOCKET_PORT=6001!WEBSOCKET_PORT=${wsport}!1" .env
    sed -i "s!PROJECT_PORT=nginx_product!PROJECT_PORT=${cproport}_nginx_product!1" .env
    sed -i "s!NGINX_NAME=nginx!NGINX_NAME=${prefix}_nginx!1" .env
    sed -i "s!CPRO_NAME=cpro!CPRO_NAME=${prefix}_cpro!1" .env
    sed -i "s!SCHED_NAME=sched!SCHED_NAME=${prefix}_sched!1" .env
    sed -i "s!GIT_BRANCH=Developer!GIT_BRANCH=${branch}!1" .env
    sed -i "s!NETWORK_NAME=default!NETWORK_NAME=${network}!1" .env
    sed -i "s!GIT_PATH=your_repos!GIT_PATH=${repos}!1" .env
    echo -e "${warn}Конфигурация .env успешно создана!${no}"
    echo -e "Теперь вы можете запустить ${ok}make build${no}"
else
    echo "Конфигурация .env уже существует"
fi