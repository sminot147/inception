.PHONY: all re up down logs clean prune fclean d

DOCKER_COMPOSE_FILE=srcs/docker-compose.yml

all: up

re: fclean up

up:
	mkdir -p /home/${USER}/data/mariadb
	mkdir -p /home/${USER}/data/wordpress
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build

d:
	mkdir -p /home/${USER}/data/mariadb
	mkdir -p /home/${USER}/data/wordpress
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build -d

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs

clean: down
	docker volume rm mariadb_data || true
	docker volume rm wordpress_data || true
	docker image rmi wordpress || true
	docker image rmi mariadb || true
	docker image rmi nginx || true
	sudo rm -rf /home/${USER}/data/mariadb
	sudo rm -rf /home/${USER}/data/wordpress

prune:
	docker system prune -af --volumes

fclean: clean prune
