# CecrUnwomen
## Steps configuration local
- mix deps.get
- make bash -> mix ecto.migrate -> mix run priv/repo/seeds.exs
- make dev


## Steps configuration on server
- install docker
- make app
- migrate db to server: docker ps, docker exec, /app/bin/migrate
- run seeds: 
  - remote to server "/app/bin/name_app remote"
  - Application.fetch_env!(:cecr_unwomen, :ecto_repos) -> CecrUnwomen.Repo -> repo
  - :code.priv_dir(:cecr_unwomen) -> "some_path"
  => Code.eval_file("/app/lib/cecr_unwomen-0.1.0/priv/repo/seeds.exs")
- deploy done, wait for cecr response
