defmodule Mix.Tasks.LookWhatHappened do
  use Mix.Task

  @start_version 0
  @batch_size 10

  @shortdoc "Makes something happen"
  def run(args) do
    Application.ensure_all_started(:commanded_json)
    # Make Sure all atoms in Struct are loaded
    Code.ensure_loaded?(CommandedJson.Events.SomethingHappened)

    stream(args)
  end

  defp stream([]) do
    do_fetch([], @start_version, @batch_size, &fetch_parsed/3)
  end

  defp stream(["raw"]) do
    config = EventStore.Config.lookup(CommandedJson.EventStore)

    do_fetch(config, @start_version, @batch_size, &fetch_raw/3)
  end

  defp do_fetch(config, start, count, fetch) do
    events = fetch.(config, start, count)

    iterate(config, start, count, fetch, events)
  end

  defp iterate(_config, _start, _count, _fetch, []), do: :ok

  defp iterate(config, start, count, fetch, events) do
    Enum.each(events, fn event ->
      IO.inspect(event.data)
    end)

    IO.puts("=====")

    new_start = start + Enum.count(events)
    events = fetch.(config, new_start, count)

    iterate(config, new_start, count, fetch, events)
  end

  defp fetch_raw(config, start, count) do
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

  defp fetch_parsed(_config, start, count) do
    {:ok, events} = CommandedJson.EventStore.read_all_streams_forward(start, count)

    events
  end
end
