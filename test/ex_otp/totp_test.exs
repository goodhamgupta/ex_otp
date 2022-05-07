defmodule ExOtp.Totp.Test do
  use ExUnit.Case
  alias ExOtp.Totp

  test "generates otp for given unix timestamp" do
    otp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()
      |> Totp.at(~U[2022-05-07 03:33:12.469370Z] |> DateTime.to_unix())

    assert otp == "446933"
  end

  test "generates otp for current time" do
    otp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()
      |> Totp.now()

    assert otp
  end
end
