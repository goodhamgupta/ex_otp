defmodule ExOtp.Behaviour do
  @moduledoc """
  This module implements the behaviour OTP classes.
  """

  alias ExOtp.{Hotp, Totp}

  @doc """
  This function accepts an integer and secret, and returns either
  a TOTP or HOTP struct
  """
  @callback new(integer(), String.t()) :: Hotp.t() | Totp.t()

  @doc """
  Function to validate the attributes of the input struct, which can be either a Totp
  or Hotp object. Returns the struct if all attributes are valid and raises an
  error otherwise.
  """
  @callback validate(Totp.t() | Hotp.t()) :: no_return() | Totp.t() | Hotp.t()

  @doc """
  Function to generate the OTP for the given timestamp value, and an optional integer value
  whic could be the interval(for Totp) or counter(for Hotp).
  """
  @callback at(Totp.t() | Hotp.t(), integer()) :: String.t()

  @doc """
  Function to check if the input otp is valid for the given algorithm(Totp or Hotp)
  and the timestamp.
  Returns true if the otp is valid and false otherwise.
  """
  @callback valid?(Totp.t() | Hotp.t(), String.t(), DateTime.t()) :: boolean()

  @doc """
  Function to generate the URI which can be used to generate QR codes,
  which can be read by 2FA apps such as Google Authenticator.
  """
  @callback provision_uri(Totp.t() | Hotp.t(), String.t(), keyword()) :: String.t()
end
