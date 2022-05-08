defmodule ExOtpTest do
  use ExUnit.Case
  doctest ExOtp

  @default_time ~U[2022-05-07 03:33:12.469370Z]

  test "generate random secret" do
    assert ExOtp.random_secret() |> String.length() == 16
    assert ExOtp.random_secret(30) |> String.length() == 30
  end

  test "returns a valid TOTP object" do
    totp = ExOtp.random_secret() |> ExOtp.create_totp(30)

    assert totp.base
    assert totp.interval == 30
  end

  test "returns a valid HOTP object" do
    hotp = ExOtp.random_secret() |> ExOtp.create_hotp(30)

    assert hotp.base
    assert hotp.initial_count == 30
  end

  test "generates a TOTP" do
    otp =
      ExOtp.random_secret()
      |> ExOtp.create_totp(30)
      |> ExOtp.generate_totp(@default_time)

    assert String.length(otp) == 6
  end

  test "generates a HOTP" do
    otp =
      ExOtp.random_secret()
      |> ExOtp.create_hotp(3)
      |> ExOtp.generate_hotp(10)

    assert String.length(otp) == 6
  end

  test "returns true if the given TOTP is valid" do
    totp = ExOtp.random_secret() |> ExOtp.create_totp(30)
    otp = ExOtp.generate_totp(totp, @default_time)

    assert ExOtp.valid_totp?(totp, otp, DateTime.add(@default_time, 1, :second))
  end

  test "returns true if the given Counter based HOTP is valid" do
    hotp = ExOtp.random_secret() |> ExOtp.create_hotp(0)
    otp = ExOtp.generate_hotp(hotp, 10)

    assert ExOtp.valid_hotp?(hotp, otp, 10)
  end

  test "returns the URI for the given totp" do
    totp = ExOtp.random_secret() |> ExOtp.create_totp(30)
    result = ExOtp.provision_uri_totp(totp, "test:shubham@google.com", issuer: "test")
    assert result
    assert String.contains?(result, "totp")
    assert String.contains?(result, "test")
    assert String.contains?(result, "shubham")
  end

  test "returns the URI for the given hotp" do
    hotp = ExOtp.random_secret() |> ExOtp.create_hotp(10)
    result = ExOtp.provision_uri_hotp(hotp, "test:shubham@google.com", issuer: "test")
    assert result
    assert String.contains?(result, "hotp")
    assert String.contains?(result, "test")
    assert String.contains?(result, "shubham")
  end

  test "generates QR code for given URI" do
    ExOtp.random_secret()
    |> ExOtp.create_totp(30)
    |> ExOtp.provision_uri_totp("test:shubham@google.com", issuer: "test")
    |> ExOtp.generate_qr_code()

    assert File.exists?("code.svg")
    File.rm("code.svg")
  end
end
