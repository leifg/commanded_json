defmodule CommandedJsonTest do
  use ExUnit.Case
  doctest CommandedJson

  test "greets the world" do
    assert CommandedJson.hello() == :world
  end
end
