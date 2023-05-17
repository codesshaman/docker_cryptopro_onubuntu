name = lar8cpro

NO_COLOR=\033[0m		# Color Reset
COLOR_OFF='\e[0m'       # Color Off
OK_COLOR=\033[32;01m	# Green Ok
ERROR_COLOR=\033[31;01m	# Error red
WARN_COLOR=\033[33;01m	# Warning yellow
RED='\e[1;31m'          # Red
GREEN='\e[1;32m'        # Green
YELLOW='\e[1;33m'       # Yellow
BLUE='\e[1;34m'         # Blue
PURPLE='\e[1;35m'       # Purple
CYAN='\e[1;36m'         # Cyan
WHITE='\e[1;37m'        # White
UCYAN='\e[4;36m'        # Cyan

all:
	@printf "$(OK_COLOR)==== Launch configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d

help:
	@echo -e "$(OK_COLOR)==== All commands of ${name} configuration ====$(NO_COLOR)"
	@echo -e "$(YELLOW)  - ______________________MAIN_________________________"
	@echo -e "$(YELLOW)  - make			: Launch configuration"
	@echo -e "$(YELLOW)  - make build			: Building configuration"
	@echo -e "$(YELLOW)  - make down			: Stopping configuration"
	@echo -e "$(YELLOW)  - make env			: Create .env-file"
	@echo -e "$(YELLOW)  - make ps			: Show configuration containers"
	@echo -e "$(YELLOW)  - make re			: Rebuild configuration$(NO_COLOR)"
	@echo -e "$(GREEN) - _____________________LARAVEL_________________________"
	@echo -e "$(GREEN) - ____________________optimize_________________________"
	@echo -e "$(GREEN) - make comup			: Do composer update"
	@echo -e "$(GREEN) - make opt			: Make php artisan optimize"
	@echo -e "$(GREEN) - make clr			: Make php optimize:clear"
	@echo -e "$(GREEN) - _____________________connect_________________________"
	@echo -e "$(GREEN) - make conn			: Connection to cryptopro"
	@echo -e "$(GREEN) - make connroot		: Connection with root"
	@echo -e "$(GREEN) - ________________________logs_________________________"
	@echo -e "$(GREEN) - make ll			: Show laravel logs"
	@echo -e "$(GREEN) - make logs			: Show cryptopro logs"
	@echo -e "$(GREEN) - make logss			: Show scheduler logs"
	@echo -e "$(GREEN) - ______________________backup_________________________"
	@echo -e "$(GREEN) - make mv			: Move laravel to laravel_old"
	@echo -e "$(GREEN) - ________________________pull_________________________"
	@echo -e "$(GREEN) - make pull			: Pull updates from git"
	@echo -e "$(GREEN) - make pullhard			: Pull with hard reset"
	@echo -e "$(GREEN) - _____________________rebuild_________________________"
	@echo -e "$(GREEN) - make recpro		: Rebuild cryptopro"
	@echo -e "$(GREEN) - make resh			: Rebuild scheduler"
	@echo -e "$(GREEN) - _______________________token_________________________"
	@echo -e "$(GREEN) - make token			: Update API token"
	@echo -e "$(GREEN) - make tokshow		: Show API token"
	@echo -e "$(GREEN) - Attention!"
	@echo -e "$(GREEN) - Start scheduler in different TTY and close it:"
	@echo -e "$(GREEN) - make sched		: Start token scheduler$(NO_COLOR)"
	@echo -e "$(PURPLE)  - _______________________NGINX_________________________"
	@echo -e "$(PURPLE)  - make logx			: Show nginx logs"
	@echo -e "$(PURPLE)  - make conx			: Connection to nginx"
	@echo -e "$(PURPLE)  - make conxroot		: Connection with root"
	@echo -e "$(PURPLE)  - make rex			: Rebuild nginx$(NO_COLOR)"
	@echo -e "$(BLUE)- ___________________WEBSOCKET_________________________"
	@echo -e "$(BLUE)- Attention!"
	@echo -e "$(BLUE)- Start websocket in different TTY and close it:"
	@echo -e "$(BLUE)- make ws			: Start websocket$(NO_COLOR)"
	@echo -e "$(ERROR_COLOR)    - _____________________CLEAN_________________________"
	@echo -e "$(ERROR_COLOR)    - make clean		: Cleaning configuration$(NO_COLOR)"

build:
	@printf "$(OK_COLOR)==== Building configuration ${name}... ====$(NO_COLOR)\n"
	@bash scripts/run.sh

clr:
	@printf "$(OK_COLOR)==== Connecting to container ${name}... ====$(NO_COLOR)\n"
	@bash scripts/clear.sh

comup:
	@printf "$(OK_COLOR)==== Do composer update ${name}... ====$(NO_COLOR)\n"
	@bash scripts/update.sh

conn:
	@printf "$(OK_COLOR)==== Connecting to container ${name}... ====$(NO_COLOR)\n"
	@bash scripts/connect.sh

connroot:
	@printf "$(OK_COLOR)==== Connecting with root ${name}... ====$(NO_COLOR)\n"
	@bash scripts/root_connect.sh

conx:
	@printf "$(OK_COLOR)==== Connecting to container ${name}... ====$(NO_COLOR)\n"
	@bash scripts/connx.sh

conxroot:
	@printf "$(OK_COLOR)==== Connecting with root ${name}... ====$(NO_COLOR)\n"
	@bash scripts/connxroot.sh

down:
	@printf "$(ERROR_COLOR)==== Stopping configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down

env:
	@printf "$(OK_COLOR)==== Create new .env ${name}... ====$(NO_COLOR)\n"
	@bash scripts/env.sh

ll:
	@printf "$(WARN_COLOR)==== Show laravel logs ${name}... ====$(NO_COLOR)\n"
	@bash scripts/laravel_logs.sh

logs:
	@printf "$(WARN_COLOR)==== Show cryptopro logs ${name}... ====$(NO_COLOR)\n"
	@bash scripts/logs.sh

logss:
	@printf "$(WARN_COLOR)==== Show scheduler logs ${name}... ====$(NO_COLOR)\n"
	@bash scripts/logss.sh

logx:
	@printf "$(WARN_COLOR)==== Show logs ${name}... ====$(NO_COLOR)\n"
	@bash scripts/logsx.sh

mv:
	@printf "$(WARN_COLOR)==== Do backup ${name}... ====$(NO_COLOR)\n"
	@bash scripts/mv_old.sh

opt:
	@printf "$(BLUE)==== Make optimize for configuration ${name}... ====$(NO_COLOR)\n"
	@bash scripts/optimize.sh

ps:
	@printf "$(BLUE)==== View configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml ps

pull:
	@printf "$(BLUE)==== Pull from repos ${name}... ====$(NO_COLOR)\n"
	@bash scripts/pull.sh

pullhard:
	@printf "$(BLUE)==== Pull from repos ${name}... ====$(NO_COLOR)\n"
	@bash scripts/hardpull.sh

re:	down
	@printf "$(OK_COLOR)==== Rebuild configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --build

recpro:
	@printf "$(ERROR_COLOR)==== Rebuild cryptopro container ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build cryptopro

resh:
	@printf "$(OK_COLOR)==== Rebuild scheduler ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml stop scheduler
	@docker-compose -f ./docker-compose.yml up -d --build --force-recreate scheduler

rex:
	@printf "$(ERROR_COLOR)==== Rebuild nginx ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build nginx

sched:
	@printf "$(OK_COLOR)==== Start token scheduler... ====$(NO_COLOR)\n"
	@bash scripts/sched.sh

token:
	@printf "$(BLUE)==== Create token ${name}... ====$(NO_COLOR)\n"
	@bash scripts/token.sh

tokshow:
	@printf "$(BLUE)==== Show token ${name}... ====$(NO_COLOR)\n"
	@bash scripts/show_token.sh

ws:
	@printf "$(OK_COLOR)==== Start websockets ${name}... ====$(NO_COLOR)\n"
	@bash scripts/socket.sh

clean: down
	@printf "$(ERROR_COLOR)==== Cleaning configuration ${name}... ====$(NO_COLOR)\n"
	@sudo rm -rf logs
	@sudo rm -rf laravel
#	@yes | docker system prune -a

fclean:
	@printf "$(ERROR_COLOR)==== Total clean of all configurations docker ====$(NO_COLOR)\n"
#	@docker stop $$(docker ps -qa)
#	@yes | docker system prune --all --force --volumes
#	@docker network prune --force
#	@docker volume prune --force

.PHONY	: all build clr comup conn connroot down logs logx logws mv opt ps pull re relar rex rews clean fclean
