defmodule ExOtp.Hotp do
  @moduledoc """
  Module for the HMAC based One-time Password algorithm.
  """

  @behaviour ExOtp.Behaviour

  alias ExOtp.{Base, Errors}
  alias __MODULE__

  @keys [
    :base,
    initial_count: 0
  ]

  @enforce_keys [:initial_count, :base]

  defstruct @keys

  @type t :: %__MODULE__{
          initial_count: Integer.t(),
          base: Base.t()
        }

  @spec new(integer(), String.t()) :: t()
  def new(initial_count, secret) do
    %Hotp{initial_count: initial_count, base: Base.new(secret)}
  end

  @spec validate(t()) :: no_return() | t()
  def validate(%Hotp{initial_count: initial_count}) when not is_integer(initial_count) do
    raise Errors.InvalidParam, "initial_count should be an integer"
  end

  def validate(hotp), do: hotp

  @spec at(ExOtp.Hotp.t(), integer) :: no_return() | String.t()
  def at(%Hotp{} = hotp, count) when is_integer(count) do
    Base.generate_otp(hotp.base, hotp.initial_count + count)
  end

  def at(_, _) do
    raise Errors.InvalidParam, "count should be an integer"
  end

  # TODO: Change the comparison to be Timing-Attack Safe.
  @spec valid?(ExOtp.Hotp.t(), String.t(), integer) :: boolean
  def valid?(%Hotp{} = hotp, otp, counter) do
    otp == at(hotp, counter)
  end

  @spec provision_uri(t(), String.t(), keyword()) :: String.t()
  def provision_uri(%Hotp{} = hotp, label, opts \\ []) do
    params = [{:secret, hotp.base.secret} | opts]
    "otpauth://hotp/#{label}?#{URI.encode_query(params, :rfc3986)}"
  end
end
