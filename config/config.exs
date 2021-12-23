import Config

config :commanded_json,
  namespace: CommandedJson,
  event_stores: [CommandedJson.EventStore]

config :commanded_json, CommandedJson.Cqrs,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: CommandedJson.EventStore
  ],
  pubsub: :local,
  registry: :local

config :commanded_json, CommandedJson.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  # serializer: CommandedJson.Serializer,
  username: "postgres",
  password: "postgres",
  database: "commanded_json_eventstore_dev",
  hostname: "localhost",
  pool_size: 10

config :commanded_json, CommandedJson.EventStore,
  column_data_type: "jsonb",
  serializer: Commanded.Serialization.JsonSerializer,
  # serializer: CommandedJson.Serializer,
  types: EventStore.PostgresTypes

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore
