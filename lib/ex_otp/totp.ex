defmodule ExOtp.Totp do
  @moduledoc """
  Module for the Time-based One-time Password algorithm.
  """

  @behaviour ExOtp.Behaviour

  alias ExOtp.Errors
  alias __MODULE__

  @keys [
    :base,
    interval: 30
  ]

  @enforce_keys [:interval, :base]

  defstruct @keys

  @type t :: %__MODULE__{
          interval: Integer.t(),
          base: ExOtp.Base.t()
        }

  @spec new(integer, String.t()) :: t()
  def new(interval, secret) do
    %Totp{interval: interval, base: ExOtp.Base.new(secret)}
  end

  @spec validate(t()) :: no_return() | t()
  def validate(%Totp{interval: interval}) when not is_integer(interval) do
    raise Errors.InvalidParam, "interval should be an integer"
  end

  def validate(totp), do: totp

  # TODO: Add support for NaiveDateTime
  @spec at(t(), DateTime.t(), integer) :: String.t()
  def at(%Totp{base: base, interval: interval}, for_time, counter \\ 0) do
    ExOtp.Base.generate_otp(
      base,
      for_time
      |> DateTime.to_unix()
      |> Kernel./(interval)
      |> floor()
      |> Kernel.+(counter)
    )
  end

  # TODO: Change the comparison to be Timing-Attack Safe.
  @spec valid?(t(), String.t(), nil | Datetime.t(), nil | integer) :: boolean
  def valid?(%Totp{} = totp, otp, for_time \\ DateTime.utc_now(), valid_window \\ 0) do
    if valid_window do
      Enum.any?(-valid_window..valid_window, fn index ->
        otp == at(totp, for_time, index)
      end)
    else
      otp == at(totp, for_time)
    end
  end

  @spec provision_uri(t(), String.t(), keyword()) :: String.t()
  def provision_uri(%Totp{} = totp, label, opts \\ []) do
    params = [{:secret, Base.decode32!(totp.base.secret)} | opts]
    "otpauth://totp/#{label}?#{URI.encode_query(params, :rfc3986)}"
  end
end
