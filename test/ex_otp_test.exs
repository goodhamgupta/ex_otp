defmodule ExOtpTest do
  use ExUnit.Case
  doctest ExOtp

  test "greets the world" do
    assert ExOtp.hello() == :world
  end
end
