import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :naughts_and_crosses, NaughtsAndCrosses.Repo,
  database: Path.expand("../naughts_and_crosses_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :naughts_and_crosses, NaughtsAndCrossesWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0w/6ELrH7fEQnqRrz2YhOESOpi9YZ1/qFQVakE5TSX39y/kgcYZJaAclWGCJJJTS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
