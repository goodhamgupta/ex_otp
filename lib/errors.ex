defmodule ExOtp.Errors.InvalidParam do
  defexception [:reason]

  def exception(reason), do: %__MODULE__{reason: reason}

  def message(%__MODULE__{reason: reason}), do: "ExOtp::InvalidParam - #{reason}"
end
