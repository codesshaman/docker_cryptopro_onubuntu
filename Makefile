name = lar8cpro
NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

all:
	@printf "$(OK_COLOR)==== Launch configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d

help:
	@echo -e "$(OK_COLOR)==== All commands of ${name} configuration ====$(NO_COLOR)"
	@echo -e "$(WARN_COLOR)- make				: Launch configuration"
	@echo -e "$(WARN_COLOR)- make build			: Building configuration"
	@echo -e "$(WARN_COLOR)- make comup			: Do composer update"
	@echo -e "$(WARN_COLOR)- make cln			: Make php optimize:clear"
	@echo -e "$(WARN_COLOR)- make conn			: Connection to container"
	@echo -e "$(WARN_COLOR)- make connroot			: Connection with root"
	@echo -e "$(WARN_COLOR)- make cows			: Connection to websocket"
	@echo -e "$(WARN_COLOR)- make down			: Stopping configuration"
	@echo -e "$(WARN_COLOR)- make logs			: Show container logs"
	@echo -e "$(WARN_COLOR)- make mv			: Move laravel to laravel_old"
	@echo -e "$(WARN_COLOR)- make opt			: Make php artisan optimize"
	@echo -e "$(WARN_COLOR)- make ps			: Show configuration containers"
	@echo -e "$(WARN_COLOR)- make pull			: Pull updates from git"
	@echo -e "$(WARN_COLOR)- make rbws			: Rebuild websockets"
	@echo -e "$(WARN_COLOR)- make re			: Rebuild configuration"
	@echo -e "$(WARN_COLOR)- make token			: Update configuration token"
	@echo -e "$(WARN_COLOR)- make tokshow			: Show configuration token"
	@echo -e "$(WARN_COLOR)- make clean			: Cleaning configuration$(NO_COLOR)"

build:
	@printf "$(OK_COLOR)==== Building configuration ${name}... ====$(NO_COLOR)\n"
	@bash scripts/run.sh
	# @docker-compose -f ./docker-compose.yml up -d --build

cln:
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

cows:
	@printf "$(OK_COLOR)==== Connecting to container ${name}... ====$(NO_COLOR)\n"
	@bash scripts/connws.sh

down:
	@printf "$(ERROR_COLOR)==== Stopping configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down

killws:
	@printf "$(ERROR_COLOR)==== Kill websocket ${name}... ====$(NO_COLOR)\n"
	@sudo kill -9 $(sudo lsof -t -i:6001)

logs:
	@printf "$(WARN_COLOR)==== Show logs ${name}... ====$(NO_COLOR)\n"
	@bash scripts/logs.sh

mv:
	@printf "$(WARN_COLOR)==== Show logs ${name}... ====$(NO_COLOR)\n"
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

rbws:
	@printf "$(OK_COLOR)==== Rebuild websocket ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml stop websocket
	@docker-compose -f ./docker-compose.yml up -d --build --force-recreate websocket

re:	down
	@printf "$(OK_COLOR)==== Rebuild configuration ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml up -d --build

token:
	@printf "$(BLUE)==== Show token ${name}... ====$(NO_COLOR)\n"
	@bash scripts/token.sh

tokshow:
	@printf "$(BLUE)==== Show token ${name}... ====$(NO_COLOR)\n"
	@bash scripts/show_token.sh

clean: down
	@printf "$(ERROR_COLOR)==== Cleaning configuration ${name}... ====$(NO_COLOR)\n"
	@sudo rm -rf logs
	@yes | docker system prune --all --volumes
#	@docker system prune -a

fclean:
	@printf "$(ERROR_COLOR)==== Total clean of all configurations docker ====$(NO_COLOR)\n"
#	@docker stop $$(docker ps -qa)
#	@docker system prune --all --force --volumes
#	@docker network prune --force
#	@docker volume prune --force

.PHONY	: all help build comup conn connroot down logs mv ps pull re clean fclean