defmodule CommandedJson.Cqrs do
  use Commanded.Application, otp_app: :commanded_json

  router(CommandedJson.Router)
end
