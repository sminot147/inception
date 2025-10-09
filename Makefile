all : up

up :
	mkdir -p /home/${USER}/data/wordpress
	mkdir -p /home/${USER}/data/wordpress
	docker-compose -f srcs/docker-compose.yml --env-file srcs/.env build

down :
	docker-compose -f srcs/docker-compose.yml down --volumes --remove-orphans