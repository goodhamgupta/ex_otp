defmodule ExOtp.Hotp.Test do
  use ExUnit.Case
  alias ExOtp.Hotp

  test "generates hotp for given unix timestamp" do
    otp =
      30
      |> Hotp.new("secret_key")
      |> Hotp.validate()
      |> Hotp.at(30)

    assert otp == "717408"
  end

  test "return true if otp is valid" do
    hotp =
      30
      |> Hotp.new("secret_key")
      |> Hotp.validate()

    otp = Hotp.at(hotp, 30)

    assert Hotp.valid?(hotp, otp, 30)
  end

  test "return false if otp is invalid" do
    hotp =
      30
      |> Hotp.new("secret_key")
      |> Hotp.validate()

    assert not Hotp.valid?(hotp, "123456", 30)
  end
end
