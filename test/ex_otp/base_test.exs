defmodule ExOtp.Base.Test do
  use ExUnit.Case

  test "generates otp" do
    base =
      %ExOtp.Base{
        digest: :sha,
        secret: Base.encode32("test"),
        digits: 6
      }
      |> ExOtp.Base.validate()

    assert ExOtp.Base.generate_otp(base, 10) == "810972"
  end
end
