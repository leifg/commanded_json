organizer_id = UUID.uuid4()

# :"CommandedJson.Events.SomethingHappened"
# Code.ensure_loaded?(CommandedJson.Events.SomethingHappened)

config = [type: "Elixir.CommandedJson.Events.SomethingHappened"]

n = 1000

struct_input = for _ <- 1..n do
  [
    %CommandedJson.Events.SomethingHappened{
      organizer: organizer_id,
      id: UUID.uuid4(),
      name: "Illegal Rave",
      awesome_level: 8,
      is_outside: false
    },
    %CommandedJson.Events.SomethingHappened{
      organizer: organizer_id,
      id: UUID.uuid4(),
      name: "Beach Day",
      awesome_level: 11,
      is_outside: true
    }
  ]
end |> List.flatten()

map_input = Enum.map(struct_input, fn struct ->
  struct |> Map.from_struct() |> Jason.encode!() |> Jason.decode!()
end)

string_input = Enum.map(struct_input, fn struct ->
  struct |> Map.from_struct() |> Jason.encode!()
end)

mapping_from_string = fn ->
  Enum.each(string_input, fn term ->
    CommandedJson.Serializer.deserialize(term, config)
  end)
end

mapping_from_map = fn ->
  Enum.each(map_input, fn term ->
    CommandedJson.Serializer.deserialize(term, config)
  end)
end

pure_string_mapping = fn ->
  Enum.each(string_input, fn term ->
    Commanded.Serialization.JsonSerializer.deserialize(term, config)
  end)
end

pure_jsonb_mapping = fn ->
  Enum.each(map_input, fn term ->
    EventStore.JsonbSerializer.deserialize(term, config)
  end)
end

jsonb_mapping_and_decoding = fn ->
  Enum.each(map_input, fn term ->
    term |> EventStore.JsonbSerializer.deserialize(config) |> Commanded.Serialization.JsonDecoder.decode()
  end)
end

Benchee.run(
  %{
    "CommandedJson.Serializer.deserialize.serialize(String)" => mapping_from_string,
    "CommandedJson.Serializer.deserialize(Map)" => mapping_from_map,
    "EventStore.JsonbSerializer.deserialize(Map)" => pure_jsonb_mapping,
    "Commanded.Serialization.JsonSerializer.deserialize(String)" => pure_string_mapping,
    "EventStore.JsonbSerializer.deserialize(Decode(Map))" => jsonb_mapping_and_decoding,
  },
  time: 10,
  memory_time: 2
)
