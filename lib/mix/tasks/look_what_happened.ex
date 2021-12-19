defmodule Mix.Tasks.LookWhatHappened do
  use Mix.Task

  @shortdoc "Makes something happen"
  def run(args) do
    Application.ensure_all_started(:commanded_json)

    stream(args)
  end

  defp stream([]) do
    {:ok, events} = CommandedJson.EventStore.read_all_streams_forward()

    events
    |> Enum.map(fn event -> event.data end)
    |> Enum.each(fn event ->
      IO.inspect(event)
      IO.puts("=====")
    end)
  end

  defp stream(["raw"]) do
    config = EventStore.Config.lookup(CommandedJson.EventStore) |> IO.inspect(label: "config")
    stream_id = 0
    start_version = 0
    count = 1000

    {:ok, events} =
      EventStore.Storage.Reader.read_forward(
        config[:conn],
        stream_id,
        start_version,
        count,
        config
      )

    Enum.each(events, fn event ->
      IO.inspect(event.data)
    end)
  end
end
