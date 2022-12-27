#!/bin/bash
GIT_PATH="https://github.com/GosZakaz/gosz-market-back.git"
GIT_BRANCH="$(grep "GIT_BRANCH" .env | sed -r 's/.{,11}//')"
NAME="$(grep "PROJECT_NAME" .env | sed -r 's/.{,13}//')"
USER_ID=$(id -u)
FOLDER=${PWD##*/}
# FILE_NAME='laravel/.env' #.env
TIMEOUT=3
ROOTENV=true
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
# Функция проверки имени проекта в конфиге nginx
check_project_name() {
  if [ -f "nginx/conf.d/default.conf" ]; then
    PCONFNAME="$(grep 'fastcgi_pass' nginx/conf.d/default.conf | sed -r 's/.{,20}//' | sed -r 's/(.+).{6}/\1/')"
    if [ "$PCONFNAME" == "$NAME" ]; then
      echo "Текущий nginx/conf.d/default.conf настроен"
    else
      sed -i "s!$PCONFNAME:9000!$NAME:9000!1" nginx/conf.d/default.conf
      echo "Меняю имя проекта в nginx/conf.d/default.conf"
    fi
  else
    echo "nginx/conf.d/default.conf not found"  
  fi
}
# Функция проверки существования .env - файла
check() {
  if [ ! -f ".env_laravel" ]; then
    ROOTENV=false
    PROJECT_NAME=$(grep "GIT_BRANCH" .env | sed -r 's/.{,11}//')
    if confirm "Не найден корневой env-файл .env_laravel, продолжить сборку? (y/n or enter for no)"; then
      echo "Продолжаю сборку без env-файла"
    else
      echo "Добавьте в сборку актуальный .env-файл под именем .env_laravel и запустите скрипт снова"
      exit
    fi
  else
    echo "Файл конфигурации nginx отсутствует!"
  fi
}
# Функция билда
run() {
  check_project_name
  docker-compose up -d --build
  sleep ${TIMEOUT}
  docker exec -it ${NAME} composer update
  sleep ${TIMEOUT}
  docker exec -it ${NAME} php artisan passport:install
  sleep ${TIMEOUT}
  docker exec -it $NAME php artisan token:generate
  # sleep ${TIMEOUT}
  docker exec -it $NAME php artisan optimize
  # sleep ${TIMEOUT}
  # docker exec -it $NAME php artisan optimize:clear
}
# Функция клонирования сборки
clone() {
  check
  git clone ${GIT_PATH} -b ${GIT_BRANCH} laravel
  if [ ! -f "laravel/.env" ]; then
    cp .env_laravel laravel/.env
  else
    if [ $ROOTENV == true ]; then
      if confirm "Заменить существующий .env-файл на корневой? (y/n or enter for no)"; then
        cp .env_laravel laravel/.env
      fi
    fi
  fi
}
# Функция смены токены
# token () {
#   if confirm "Сменить токен? (y/n or enter for no)"; then
#     docker-compose down
#     TKN_STRING=$(grep -n 'TOKEN_PURCHASE' ${FILE_NAME} | cut -d: -f1)
#     let REMOVE_STR=$TKN_STRING+1
#     sed -i "${TKN_STRING}d" ${FILE_NAME}
#     read -p 'Введите новый токен: ' TOKEN_PURCHASE
#     sed -i "${TKN_STRING}i\TOKEN_PURCHASE='${TOKEN_PURCHASE}'\n" ${FILE_NAME}
#     sed -i "${TKN_STRING}i\TOKEN_PURCHASE='${TOKEN_PURCHASE}'\n" .env
#     sed -i "${REMOVE_STR}d" ${FILE_NAME}
#     run
#   else
#     run
# #    docker-compose up -d --build
#   fi
# }
# Тело скрипта
if [ ! -d "laravel/" ]; then
  clone
  echo "Запускаю конфигурацию ${FOLDER}!"
  run
else
  echo "Запускаю конфигурацию ${FOLDER}!"
  run
fi
