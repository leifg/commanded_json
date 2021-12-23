defmodule CommandedJson.Events.SomethingHappened do
  @derive Jason.Encoder
  defstruct organizer: nil,
            id: nil,
            name: nil,
            awesome_level: 0,
            is_outside: false,
            happening_at: Date.utc_today(),
            created_at: DateTime.utc_now()

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%CommandedJson.Events.SomethingHappened{} = event) do
      dt_happening_at =
        event.happening_at &&
          case Date.from_iso8601(event.happening_at) do
            {:ok, parsable_date} -> parsable_date
            {:error, _} -> nil
          end

      dt_created_at =
        event.created_at &&
          case DateTime.from_iso8601(event.created_at) do
            {:ok, parsable_date, _offset} -> parsable_date
            {:error, _} -> nil
          end

      %CommandedJson.Events.SomethingHappened{
        event
        | happening_at: dt_happening_at,
          created_at: dt_created_at
      }
    end
  end
end
