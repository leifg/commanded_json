defmodule Mix.Tasks.MigrateEvents do
  use Mix.Task

  @start_version 0
  @batch_size 10

  @shortdoc "migrate existing events"
  def run(_args) do
    Application.ensure_all_started(:commanded_json)
    # Make Sure all atoms in Struct are loaded
    Code.ensure_loaded?(CommandedJson.Events.SomethingHappened)

    config = EventStore.Config.lookup(CommandedJson.EventStore)

    {:ok, _} = Postgrex.query(config[:conn], drop_update_trigger(), [], config)

    do_fetch(config, @start_version, @batch_size, &fetch/3)

    {:ok, _} = Postgrex.query(config[:conn], create_update_trigger(), [], config)
  end

  defp do_fetch(config, start, count, fetch) do
    events = fetch.(config, start, count)

    iterate(config, start, count, fetch, events)
  end

  defp iterate(_config, _start, _count, _fetch, []), do: :ok

  defp iterate(config, start, count, fetch, events) do
    new_start = start + Enum.count(events)
    events = fetch.(config, new_start, count)

    Enum.each(events, &migrate(&1, config))

    iterate(config, new_start, count, fetch, events)
  end

  defp fetch(config, start, count) do
    {:ok, events} =
      EventStore.Storage.Reader.read_forward(
        config[:conn],
        0,
        start,
        count,
        config
      )

    events
  end

  defp migrate(%{event_id: event_id, data: data, metadata: metadata}, opts)
       when is_bitstring(data) or is_bitstring(metadata) do
    {schema, opts} = Keyword.pop(opts, :schema)

    parameters = [
      safe_decode(data),
      safe_decode(metadata),
      UUID.string_to_binary!(event_id)
    ]

    {:ok, _} = Postgrex.query(opts[:conn], update_statement(schema), parameters, opts)

    IO.puts("migrated event #{event_id}")
  end

  defp migrate(%{event_id: event_id}, _opts) do
    IO.puts("Skipped event #{event_id}")
  end

  defp safe_decode(json) when is_bitstring(json), do: Jason.decode!(json)
  defp safe_decode(json), do: json

  defp update_statement(schema) do
    """
    UPDATE
      #{schema}.events
    SET
      data = $1,
      metadata = $2
    where event_id = $3;

    """
  end

  defp create_update_trigger do
    """
      CREATE TRIGGER no_update_events
      BEFORE UPDATE ON events
      FOR EACH STATEMENT
      EXECUTE PROCEDURE event_store_exception('Cannot update events');
    """
  end

  defp drop_update_trigger do
    """
      DROP TRIGGER IF EXISTS no_update_events on events;
    """
  end
end
