# ExOtp

This library allows you to create One-Time-Passwords, which can be either Time-based One-Time Passwords(TOTP) and Counter based OTPs(via HMAC-based One Time Passwords(HOTP)). 

The library is primarily based on the [PyOTP](https://github.com/pyauth/pyotp), and almost exactly mirrors their API as well.

The library provides the following features:

- Generate TOTP or Counter based HOTP

**Usage**

## Installation

You can install `ex_otp` by adding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_otp, "~> 0.1.0"}
  ]
end
```

# Alternatives

Dashbit also has an amazing library for generating OTP's called [nimble_totp](https://github.com/dashbitco/nimble_totp). 

# Credits
- [PyOTP](https://github.com/pyauth/pyotp) - The API and implementation is largely based on PyOTP.
- [Nimble TOTP](https://github.com/dashbitco/nimble_totp) - Generally, I used this library to check the correctness of my implementation :) I also aim to add benchmarks tests comparing our libraries in the future!