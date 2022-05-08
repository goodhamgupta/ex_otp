defmodule ExOtp.Errors.InvalidParam do
  @moduledoc """
  Module to display a custom message when a parameter receives an invalid value.
  """
  defexception [:reason]

  def exception(reason), do: %__MODULE__{reason: reason}

  def message(%__MODULE__{reason: reason}), do: "ExOtp::InvalidParam - #{reason}"
end

defmodule ExOtp.Errors.MissingDependency do
  @moduledoc """
  Module to display a custom message when there is a missing dependency.
  """
  defexception [:reason]

  def exception(reason), do: %__MODULE__{reason: reason}

  def message(%__MODULE__{reason: reason}), do: "ExOtp::MissingDependency- #{reason}"
end
