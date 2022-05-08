defmodule ExOtp.Totp.Test do
  use ExUnit.Case
  alias ExOtp.Totp

  @default_time ~U[2022-05-07 03:33:12.469370Z]

  test "generates otp for given unix timestamp" do
    otp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()
      |> Totp.at(@default_time)

    assert otp == "446933"
  end

  test "returns true if given otp is valid" do
    totp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()

    otp = Totp.at(totp, @default_time)

    assert Totp.valid?(totp, otp, @default_time)
  end

  test "returns false if given otp is invalid" do
    totp =
      30
      |> Totp.new("secret_key")
      |> Totp.validate()

    assert not Totp.valid?(totp, "123456", @default_time)
  end
end
