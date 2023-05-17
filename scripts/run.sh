#!/bin/bash
git="$(grep "GIT_PATH" .env | sed -r 's/.{,9}//')"
branch="$(grep "GIT_BRANCH" .env | sed -r 's/.{,11}//')"
cproname="$(grep "CPRO_NAME" .env | sed -r 's/.{,10}//')"
no='\033[0m'
ok='\033[1;32m'
blue='\033[0;34m'
warn='\033[33;01m'
error='\033[31;01m'
folder=${PWD##*/}
timeout=1
rootenv=true
mypath=${PWD}
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
# Функция создания файла с окружением
if [ ! -f .env ]; then
    echo -e "${blue}[CryptoPro]${no}${warn}.env-файл отсутствует.${no}"
    echo -e "${blue}[CryptoPro]${no}${warn}Воспользуйтесь командой${no} ${ok}make env${no} ${warn}для его создания${no}"
    exit
fi
# Функция проверки имени проекта в конфиге nginx
check_project_name() {
  if [ -f "nginx/conf.d/default.conf" ]; then
    pconfname="$(grep 'fastcgi_pass' nginx/conf.d/default.conf | sed -r 's/.{,20}//' | sed -r 's/(.+).{6}/\1/')"
    if [ "$pconfname" == "$cproname" ]; then
      echo -e "${blue}[CryptoPro]${no}${warn}Текущий nginx/conf.d/default.conf настроен${no}"
    else
      sed -i "s!$pconfname:9001!$cproname:9001!1" nginx/conf.d/default.conf
      echo -e "${blue}[CryptoPro]${no}${warn}Меняю имя проекта в nginx/conf.d/default.conf${no}"
    fi
  else
    echo -e "${blue}[CryptoPro]${no}${error} Конфигурационный файл nginx не найден!${no}"  
  fi
}
# Функция проверки существования .env - файла
check_env() {
  if [ ! -f ".env.local" ]; then
    if [ ! -f ".env.product" ]; then
      rootenv=false
      if confirm "Не найдены корневые env-файлы .env.local и .env.product, продолжить сборку? (y/n or enter for no)"; then
        echo -e "${blue}[CryptoPro]${no}${warn}Продолжаю сборку без env-файлов${no}"
      else
        echo -e "${blue}[CryptoPro]${no}${warn}Добавьте в сборку актуальные .env-файлы для локального и удалённого запуска и выполните сборку снова${no}"
        exit
      fi
    else
      echo -e "${blue}[CryptoPro]${no}${warn}Файлы конфигурации .env отсутствуют!${no}"
    fi
  fi
}
# Функция билда
run() {
  check_project_name
  docker-compose up -d --build
  sleep ${timeout}
  docker exec -it ${cproname} composer update --ignore-platform-req=ext-curl
  sleep ${timeout}
  docker exec -it ${cproname} php artisan passport:install
  sleep ${timeout}
  docker exec -it ${cproname} php artisan token:generate
  sleep ${timeout}
  docker exec -it ${cproname} php artisan optimize
  sleep ${timeout}
  # docker exec -it ${cproname} php artisan optimize:clear
  make resh
}
# Функция клонирования сборки
clone() {
  check_env
  git clone ${git} -b ${branch} laravel
  if [ $rootenv == true ]; then
    if confirm "Применить production-config? (y/n or enter for no)"; then
      if [ -f "laravel/.env" ]; then
        mv laravel/.env laravel/.env.origin
      fi
      echo -e "${blue}[CryptoPro]${no}${warn}Копирую конфигурацию для удалённого сервера${no}"
      pth=($(echo "${mypath}" | tr '/' '\n'))
      address=${pth[-1]}
      adress=($(echo "${address}" | tr '.' '\n'))
      subdomain=${adress[-3]}
      domain=${adress[-2]}
      zone=${adress[-1]}
      hosts=$(cat .env.product | grep 'HOST=' | grep -oE '([[:alnum:]-]+\.){1,}+[[:alpha:]]{2,}')
      host=($(echo "${hosts}" | tr ' ' '\n'))
      if [ ${host[0]} != $address ]; then
          echo -e "${blue}[CryptoPro]${no}${warn}Произвожу настройки доменного имени${no}"
          sed -i "s!HOST=${host[0]}!HOST=${address}!1" .env.product
          echo -e "${blue}[CryptoPro]${no}${ok}Доменное имя изменено на ${ok}${address}${no}"
      else
          echo -e "${blue}[CryptoPro]${no}${ok}Доменное имя уже настроено${no}"
      fi
      cp .env.product laravel/.env
    else
      if [ -f "laravel/.env" ]; then
        mv laravel/.env laravel/.env.origin
      fi
      echo -e "${blue}[CryptoPro]${no}${warn}Копирую конфигурацию для локального хоста${no}"
      cp .env.local laravel/.env
    fi
  else
      echo -e "${blue}[CryptoPro]${no}${warn}Файлы конфигурации .env отсутствуют, запускаюсь на предоставленном репозиторием${no}"
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
  echo -e "${blue}[CryptoPro]${no}${warn}Запускаю конфигурацию ${folder}!${no}"
  run
else
  echo -e "${blue}[CryptoPro]${no}${warn}Запускаю конфигурацию ${folder}!${no}"
  run
fi
make ps
echo -e "${blue}[CryptoPro]${no}${warn}Не забудьте запустить websocker в отдельном TTY:${no}"
echo -e "${blue}[CryptoPro]${no}${ok}make ws${no}"