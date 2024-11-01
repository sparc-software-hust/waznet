dev: 
	docker compose -f docker_compose_dev.yaml --env-file .env.dev run --name unwomen --rm -p 4000:4000 api iex -S mix phx.server
bash:
	docker exec -it unwomen sh
app:
	docker compose rm -sf; \
	docker compose -f docker_compose_prod.yaml --env-file .env.prod up --build --detach; \
	docker image prune -f