defmodule CommandedJson.Aggregates.Organizer do
  defstruct id: nil,
            made_it_happen: MapSet.new([])

  alias CommandedJson.Aggregates.Organizer
  alias CommandedJson.Commands.MakeSomethingHappen
  alias CommandedJson.Events.SomethingHappened

  def execute(%Organizer{}, %MakeSomethingHappen{} = command) do
    %SomethingHappened{
      id: command.id,
      organizer: command.organizer,
      name: command.name,
      awesome_level: command.awesome_level,
      is_outside: command.is_outside
    }
  end

  def apply(%Organizer{} = organizer, %SomethingHappened{id: id, organizer: organizer_id}) do
    %CommandedJson.Aggregates.Organizer{
      id: organizer_id,
      made_it_happen: MapSet.put(organizer.made_it_happen, id)
    }
  end
end
