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

  test "returns true if given otp is valid" do
    totp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()

    time = ~U[2022-05-07 03:33:12.469370Z]
    otp = Totp.at(totp, time |> DateTime.to_unix())

    assert Totp.valid?(totp, otp, time)
  end

  test "returns false if given otp is invalid" do
    totp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()

    time = ~U[2022-05-07 03:33:12.469370Z]
    otp = "123456"

    assert not Totp.valid?(totp, otp, time)
  end
end
