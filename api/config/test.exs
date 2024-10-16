import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cecr_unwomen, CecrUnwomen.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cecr_unwomen_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cecr_unwomen, CecrUnwomenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "MIYBY67STLhevHG3R2MSmPj+4o4k1w5HibaU5wgk5Haj5fstleW/TkMwsQ3WajUt",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
