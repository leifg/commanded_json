defmodule CommandedJson.Serializer do
  @moduledoc """
  Serialize to/from PostgreSQL's native `jsonb` format.
  """

  @behaviour EventStore.Serializer

  alias Commanded.Serialization.JsonSerializer
  alias EventStore.JsonbSerializer

  def serialize(term), do: JsonbSerializer.serialize(term)

  # Backwards compatibility function
  def deserialize(term, config) when is_bitstring(term),
    do: JsonSerializer.deserialize(term, config)

  def deserialize(term, config),
    do:
      term |> JsonbSerializer.deserialize(config) |> Commanded.Serialization.JsonDecoder.decode()
end
