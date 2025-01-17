dev: 
	docker compose -f docker_compose_dev.yaml --env-file .env.dev run --name api --rm -p 4000:4000 api iex -S mix phx.server
bash:
	docker exec -it api bash
app:
	docker compose -f docker_compose_prod.yaml down && \
	docker compose -f docker_compose_prod.yaml --env-file .env.prod up --build --detach; \
	docker image prune -f 

logs:
	docker compose -f docker_compose_prod.yaml logs -f