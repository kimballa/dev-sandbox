IMAGE := sandbox-dev
CONTAINER := sandbox

.PHONY: build up down shell logs clean rebuild

build:
	docker compose build

rebuild:
	docker compose build --no-cache

up:
	./up

down:
	./down

shell:
	docker exec -it $(CONTAINER) /bin/bash

logs:
	docker compose logs -f

clean:
	docker compose down -v --rmi local
