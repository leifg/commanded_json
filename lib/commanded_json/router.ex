defmodule CommandedJson.Router do
  use Commanded.Commands.Router

  alias CommandedJson.Aggregates.Organizer
  alias CommandedJson.Commands.MakeSomethingHappen

  identify(Organizer, by: :organizer)

  dispatch(
    [
      MakeSomethingHappen
    ],
    to: Organizer
  )
end
