defmodule ExOtp do
  @moduledoc """
  Documentation for `ExOtp`.
  """
  alias ExOtp.{Totp, Hotp}

  def create_totp(interval \\ 30, secret \\ "secret") do
    Totp.new(interval, secret) |> Totp.validate()
  end

  def create_hotp(initial_count \\ 0, secret \\ "secret") do
    Hotp.new(initial_count, secret) |> Hotp.validate()
  end

  def generate_totp(%Totp{} = totp, for_time, counter \\ 0) do
    Totp.at(totp, for_time, counter)
  end

  def generate_hotp(%Hotp{} = hotp, count) do
    Hotp.at(hotp, count)
  end

  def valid_totp?(%Totp{} = totp, otp, for_time \\ DateTime.utc_now(), valid_window \\ 0) do
    Totp.valid?(totp, otp, for_time, valid_window)
  end

  def valid_hotp?(%Hotp{} = hotp, otp, counter) do
    Hotp.valid?(hotp, otp, counter)
  end
end
