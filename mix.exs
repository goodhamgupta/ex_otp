defmodule ExOtp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_otp,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eqrcode, "~> 0.1.10", optional: true}
    ]
  end
end
