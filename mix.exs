defmodule ExOtp.MixProject do
  use Mix.Project

  @version "0.0.1"
  @repo_url "https://github.com/goodhamgupta/ex_otp/"

  def project do
    [
      app: :ex_otp,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      # Hex
      package: package(),
      description: "OTP(One-Time-Password) Library in Elixir based on PyOTP",

      # Docs
      name: "ExOtp",
      docs: docs()
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
      {:eqrcode, "~> 0.1.10", optional: true},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.19.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp docs do
    [
      main: "ExOtp",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
