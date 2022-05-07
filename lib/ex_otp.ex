defmodule ExOtp do
  @moduledoc """
  Documentation for `ExOtp`.
  """
  alias ExOtp.{Errors, Hotp, Totp}

  @spec random_secret(integer()) :: no_return() | bitstring
  def random_secret(length \\ 16) do
    if length < 16 do
      raise Errors.InvalidParam, "secret length should be atleast 16 characters"
    end

    for _ <- 1..length, into: "", do: <<Enum.random('0123456789abcdef')>>
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
end
