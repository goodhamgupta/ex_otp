defmodule ExOtp do
  @moduledoc """
  ExOtp allows you to create One-Time-Passwords, which can be either Time-based One-Time Passwords(TOTP) and Counter based OTPs(via HMAC-based One Time Passwords(HOTP)).

  The library is primarily based on the [PyOTP](https://github.com/pyauth/pyotp), and almost exactly mirrors their API as well. It follows the MFA standards defined in [RFC4226](https://datatracker.ietf.org/doc/html/rfc4226)(HOTP: an Hmac-Based One-Time Password Algorithm) and [RFC6238](https://datatracker.ietf.org/doc/html/rfc6238)(TOTP: Time-Based One-Time Password Algorithm).

  The library provides the following features:

  - Generate TOTP or Counter based HOTP
  - Generate QR codes for OTPs
  - Generate random secret values(if required)

  ## Usage

  ### TOTP

  - Create a TOTP object using either a random secret or  a user-provided secret as follows:

  Example:

      secret = ExOtp.random_secret()
      #=> "uapgaiacdaptafbu"
      totp = ExOtp.create_totp(secret, 30) # Specify interval for which the OTP will be valid.
      #=> %ExOtp.Totp{
      #  base: %ExOtp.Base{
      #    digest: :sha,
      #    digits: 6,
      #    secret: "OVQXAZ3BNFQWGZDBOB2GCZTCOU======"
      #  },
      #  interval: 30
      #}

  - Generate an otp using the `totp` object, for a given datetime value:

  Example:

      otp = ExOtp.generate_totp(totp, DateTime.utc_now())
      #=> "967372"

  - Finally, you can check if the otp is valid using the `otp` and `totp` objects:

  Example:

      ExOtp.valid_totp?(totp, otp, DateTime.utc_now())
      #=> true

  ### HOTP

  - Create a HOTP object using either a random secret or  a user-provided secret as follows:

  Example:

      secret = ExOtp.random_secret()
      #=> "uapgaiacdaptafbu"
      hotp = ExOtp.create_hotp(secret, 30) # Specify initial count
      #=> %ExOtp.Hotp{
      #  base: %ExOtp.Base{
      #    digest: :sha,
      #    digits: 6,
      #    secret: "OVQXAZ3BNFQWGZDBOB2GCZTCOU======"
      #  },
      #  initial_count: 0
      #}

  - Generate an otp using the `hotp` object, for a given datetime value:

  Example:

      otp = ExOtp.generate_hotp(hotp, DateTime.utc_now())
      #=> "268374"

  - Finally, you can check if the otp is valid using the `otp` and `hotp` objects:

  Example:

      ExOtp.valid_hotp?(hotp, otp, 0) # Specify counter value
      #=> true

  ### QR Code(Optional)

  - Generate the provision URI for use with a QR code scanner built into MFA apps such as Google Authenticator.
  - Generate the QR code using the `EQRCode` libraby, which is an optional dependency.
  - Given a `totp` object and an `otp`, you can generate the QR code using:

  Example:

      totp
      |> ExOtp.provision_uri_totp(otp, "test:shubham@google.com",issuer_name: "test")
      |> ExOtp.generate_qr_code("code.svg")
      #=> 09:51:17.102 [info]  QR code written to file: code.svg

  """
  alias ExOtp.{Errors, Hotp, Totp}

  require Logger

  @spec random_secret(integer()) :: no_return() | String.t()
  def random_secret(length \\ 16) do
    if length < 16 do
      raise Errors.InvalidParam, "secret length should be atleast 16 characters"
    end

    for _ <- 1..length, into: "", do: <<Enum.random('abcdefghijklmnopqrstuvwxyz')>>
  end

  @spec create_totp(String.t(), integer()) :: Totp.t()
  def create_totp(secret, interval \\ 30) do
    Totp.new(interval, secret) |> Totp.validate()
  end

  @spec create_hotp(String.t(), integer()) :: Hotp.t()
  def create_hotp(secret, initial_count \\ 0) do
    Hotp.new(initial_count, secret) |> Hotp.validate()
  end

  @spec generate_totp(Totp.t(), DateTime.t(), integer) :: String.t()
  def generate_totp(%Totp{} = totp, for_time, counter \\ 0) do
    Totp.at(totp, for_time, counter)
  end

  @spec generate_hotp(Hotp.t(), integer) :: String.t()
  def generate_hotp(%Hotp{} = hotp, count) do
    Hotp.at(hotp, count)
  end

  @spec valid_totp?(Totp.t(), String.t(), DateTime.t(), integer) :: boolean
  def valid_totp?(%Totp{} = totp, otp, for_time \\ DateTime.utc_now(), valid_window \\ 0) do
    Totp.valid?(totp, otp, for_time, valid_window)
  end

  @spec valid_hotp?(ExOtp.Hotp.t(), String.t(), integer) :: boolean
  def valid_hotp?(%Hotp{} = hotp, otp, counter) do
    Hotp.valid?(hotp, otp, counter)
  end

  @spec provision_uri_totp(Totp.t(), String.t(), keyword) :: String.t()
  def provision_uri_totp(totp, label, opts \\ []) do
    Totp.provision_uri(totp, label, opts)
  end

  @spec provision_uri_hotp(Hotp.t(), String.t(), keyword) :: String.t()
  def provision_uri_hotp(hotp, label, opts \\ []) do
    Hotp.provision_uri(hotp, label, opts)
  end

  def generate_qr_code(input, filename \\ "code.svg") do
    unless Code.ensure_compiled(EQRCode) do
      raise Errors.MissingDependency,
            "Please install the optional depndency EQRCode to generate the QR code"
    end

    input |> EQRCode.encode() |> EQRCode.svg() |> (&File.write!(filename, &1)).()
    Logger.info("QR code written to file: #{filename}")
  end
end
