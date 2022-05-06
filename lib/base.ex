defmodule ExOtp.Base do
  @moduledoc """
  Base file containing common functions for generating the One-time Password algorithms.
  """

  alias ExOtp.Errors
  alias Base, as: ElixirBase
  alias __MODULE__

  use Bitwise

  @keys [
    :digits,
    :digest,
    :secret,
    :issuer,
    name: "secret"
  ]

  defstruct @keys

  @max_padding 8

  @type t :: %__MODULE__{
          digits: Integer.t(),
          digest: atom(),
          name: String.t(),
          issuer: String.t()
        }

  def validate(%__MODULE__{digest: digest}) when is_nil(digest) do
    raise Errors.InvalidParam,
          "digest cannot be blank. Should be one of: md5, sha1, sha256, sha512"
  end

  def validate(%__MODULE__{digits: digits}) when is_nil(digits) do
    raise Errors.InvalidParam, "digits cannot be blank. Should be an integer between 6 and 8"
  end

  def validate(%__MODULE__{digits: digits}) when digits < 0 do
    raise Errors.InvalidParam, "digits cannot be less than 0."
  end

  def validate(base), do: base

  def generate_otp(_base, input) when input < 0 do
    raise Errors.InvalidParam, "input must be a positive integer"
  end

  def generate_otp(_base, input) when not is_integer(input) do
    raise Errors.InvalidParam, "input must be an integer."
  end

  def generate_otp(%Base{} = base, input) when is_integer(input) do
    secret = byte_secret(base, rem(String.length(base.secret), @max_padding))
    :crypto.mac(:hmac, base.digest, secret, input)
  end

  def byte_secret(%Base{} = base, missing_padding) when missing_padding == 0 do
    ElixirBase.decode32("#{base.secret}")
  end

  def byte_secret(%Base{} = base, missing_padding) when missing_padding > 0 do
    padding = String.duplicate("=", @max_padding - missing_padding)
    ElixirBase.decode32("#{base.secret}#{padding}")
  end

  def int_to_binary(input, padding \\ @max_padding) do
    do_byte_generation(input)
  end

  @spec do_byte_generation(any, any) :: any
  def do_byte_generation(input, result \\ <<>>) do
    if input == 0 do
      pad = @max_padding - byte_size(result)
      <<0::pad*8, result::binary>>
    else
      do_byte_generation(input >>> 8, <<input &&& 0xFF::utf8>> <> result)
    end
  end
end
