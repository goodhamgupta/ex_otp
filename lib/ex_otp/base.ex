defmodule ExOtp.Base do
  @moduledoc """
  Base file containing common functions for generating the One-time Password algorithms.
  """

  alias ExOtp.Errors
  alias Base, as: ElixirBase

  use Bitwise

  @keys [
    :secret,
    digits: 6,
    digest: :sha
  ]

  defstruct @keys

  @max_padding 8

  @type t :: %__MODULE__{
          secret: String.t(),
          digits: Integer.t(),
          digest: atom()
        }

  def new(secret) do
    %__MODULE__{secret: Base.encode32(secret)}
  end

  @doc """
  Function to validate the attributes for the Base struct.
  """
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

  @doc """
  Function to generate the OTP, given an input.
  """
  @spec generate_otp(ExOtp.Base.t(), integer) :: no_return() | String.t()
  def generate_otp(_base, input) when input < 0 do
    raise Errors.InvalidParam, "input must be a positive integer"
  end

  def generate_otp(_base, input) when not is_integer(input) do
    raise Errors.InvalidParam, "input must be an integer."
  end

  def generate_otp(%__MODULE__{} = base, input) when is_integer(input) do
    {:ok, secret} = byte_secret(base, rem(String.length(base.secret), @max_padding))

    code =
      :hmac
      |> :crypto.mac(base.digest, secret, int_to_binary(input))
      |> :binary.bin_to_list()
      |> generate_code(base)

    num_digits = code |> Integer.digits() |> length()

    if num_digits < base.digits do
      "0#{code}"
    else
      "#{code}"
    end
  end

  @spec generate_code(list(Integer.t()), ExOtp.Base.t()) :: non_neg_integer
  defp generate_code(bin_list, %__MODULE__{digits: digits}) do
    offset = Enum.fetch!(bin_list, -1) &&& 0xF

    [zero, one, two, three] =
      Enum.map(0..3, fn index ->
        Enum.fetch!(bin_list, offset + index)
      end)

    (zero &&& 0x7F) <<< 24
    |> bor((one &&& 0xFF) <<< 16)
    |> bor((two &&& 0xFF) <<< 8)
    |> bor(three &&& 0xFF)
    # Floor is required to convert float to integer
    |> rem(:math.pow(10, digits) |> floor())
  end

  # Private API

  defp byte_secret(%__MODULE__{secret: secret}, missing_padding) when missing_padding == 0 do
    ElixirBase.decode32("#{secret}")
  end

  defp byte_secret(%__MODULE__{secret: secret}, missing_padding) when missing_padding > 0 do
    padding = String.duplicate("=", @max_padding - missing_padding)
    ElixirBase.decode32("#{secret}#{padding}")
  end

  defp int_to_binary(input) do
    do_byte_generation(input)
  end

  @spec do_byte_generation(any, any) :: any
  defp do_byte_generation(input, result \\ <<>>) do
    if input == 0 do
      pad = @max_padding - byte_size(result)
      <<0::pad*8, result::binary>>
    else
      do_byte_generation(input >>> 8, <<input &&& 0xFF::utf8>> <> result)
    end
  end
end
