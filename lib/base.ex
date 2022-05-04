defmodule ExOtp.Base do
  @moduledoc """
  Base file containing common functions for generating the One-time Password algorithms.
  """

  alias ExOtp.Errors
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

  @MAX_PADDING 8

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

  def generate_otp(_base, input) when not is_integer(input) do
    raise Errors.InvalidParam, "input must be an integer."
  end

  def generate_otp(%Base{} = base, input) when is_integer(input) do
    _secret = byte_secret(base, rem(String.length(base.secret), @MAX_PADDING))
  end

  defp byte_secret(%Base{} = base, missing_padding) when missing_padding == 0 do
    :base32.decode("#{base.secret}")
  end

  defp byte_secret(%Base{} = base, missing_padding) when missing_padding > 0 do
    padding = String.duplicate('=', @MAX_PADDING - missing_padding)
    :base32.decode("#{base.secret}#{padding}")
  end

  defp int_to_bytestring(input, padding \\ @MAX_PADDING) do
    do_byte_generation(input)

  end
end
