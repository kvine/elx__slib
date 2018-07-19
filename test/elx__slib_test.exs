defmodule ElxSlibTest do
  use ExUnit.Case
  doctest ElxSlib

  test "greets the world" do
    assert ElxSlib.hello() == :world
  end
end
