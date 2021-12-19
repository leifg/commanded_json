defmodule Mix.Tasks.MakeItHappen do
  use Mix.Task

  @shortdoc "Makes something happen"
  def run(_args) do
    Application.ensure_all_started(:commanded_json)

    organizer_id = UUID.uuid4()

    command = %CommandedJson.Commands.MakeSomethingHappen{
      organizer: organizer_id,
      id: UUID.uuid4(),
      name: "Illegal Rave",
      awesome_level: 8,
      is_outside: false
    }

    CommandedJson.Cqrs.dispatch(command, consistency: :eventual)

    command = %CommandedJson.Commands.MakeSomethingHappen{
      organizer: organizer_id,
      id: UUID.uuid4(),
      name: "Beach Day",
      awesome_level: 11,
      is_outside: true
    }

    CommandedJson.Cqrs.dispatch(command, consistency: :eventual)
  end
end
