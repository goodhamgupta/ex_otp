defmodule ExOtp.Totp do
  @moduledoc """
  Module for the Time-based One-time Password algorithm.
  """

  alias ExOtp.{Base, Errors}
  alias __MODULE__

  @keys [
    :base,
    interval: 30
  ]

  @enforce_keys [:interval, :base]

  defstruct @keys

  @type t :: %__MODULE__{
          interval: Integer.t(),
          base: Base.t()
        }

  def validate(%Totp{interval: interval}) when not is_integer(interval) do
    raise Errors.InvalidParam, "interval should be an integer"
  end

  def validate(totp), do: totp

  def at(%Totp{base: base, interval: interval}, for_time) when is_integer(for_time) do
    Base.generate_otp(base, (for_time / interval) |> round())
  end

  def at(%Totp{base: base, interval: interval}, %DateTime{} = for_time) do
    Base.generate_otp(base, (DateTime.to_unix(for_time) / interval) |> round())
  end

  def at(_, _) do
    raise Errors.InvalidParam, "interval should be an integer or DateTime value"
  end
end
