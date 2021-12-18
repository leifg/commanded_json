defmodule CommandedJson.Events.SomethingHappened do
  @derive Jason.Encoder
  defstruct organizer: nil,
            id: nil,
            name: nil,
            awesome_level: 0,
            is_outside: false
end
