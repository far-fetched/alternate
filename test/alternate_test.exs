defmodule AlternateTest do
  use ExUnit.Case
  doctest Alternate

  test "greets the world" do
    assert Alternate.hello() == :world
  end
end
