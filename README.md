# ExOtp

ExOtp allows you to create One-Time-Passwords, which can be either Time-based One-Time Passwords(TOTP) and Counter based OTPs(via HMAC-based One Time Passwords(HOTP)). 

The library is primarily based on the [PyOTP](https://github.com/pyauth/pyotp), and almost exactly mirrors their API as well. It follows the MFA standards defined in [RFC4226](https://datatracker.ietf.org/doc/html/rfc4226)(HOTP: an Hmac-Based One-Time Password Algorithm) and [RFC6238](https://datatracker.ietf.org/doc/html/rfc6238)(TOTP: Time-Based One-Time Password Algorithm).

The library provides the following features:

- Generate TOTP or Counter based HOTP
- Generate QR codes for OTPs
- Generate random secret values(if required)

The full documentation is available [here](https://hexdocs.pm/ex_otp/).

## Installation

You can install `ex_otp` by adding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_otp, "~> 0.0.1"}
  ]
end
```

## Usage

### TOTP

- You can create a TOTP object using either a random secret or  a user-provided secret as follows:
```elixir
secret = ExOtp.random_secret()
#=> "uapgaiacdaptafbu"
totp = ExOtp.create_totp(secret, 30) # Specify interval for which the OTP will be valid.
#=> %ExOtp.Totp{
#  base: %ExOtp.Base{
#    digest: :sha,
#    digits: 6,
#    secret: "OVQXAZ3BNFQWGZDBOB2GCZTCOU======"
#  },
#  interval: 30
#}
```

- You can then generate an otp using the `totp` object, for a given datetime value:
```elixir
otp = ExOtp.generate_totp(totp, DateTime.utc_now())
#=> "967372"
```

- Finally, you can check if the otp is valid using the `otp` and `totp` objects:

```elixir
ExOtp.valid_totp?(totp, otp, DateTime.utc_now())
#=> true
```

### HOTP

- Create a HOTP object using either a random secret or  a user-provided secret as follows:
```elixir
secret = ExOtp.random_secret()
#=> "uapgaiacdaptafbu"
totp = ExOtp.create_hotp(secret, 30) # Specify initial count 
#=> %ExOtp.Hotp{
#  base: %ExOtp.Base{
#    digest: :sha,
#    digits: 6,
#    secret: "OVQXAZ3BNFQWGZDBOB2GCZTCOU======"
#  },
#  initial_count: 0
#}
```

- Generate an otp using the `hotp` object, for a given datetime value:
```elixir
otp = ExOtp.generate_hotp(hotp, DateTime.utc_now())
#=> "268374"
```

- Finally, you can check if the otp is valid using the `otp` and `hotp` objects:

```elixir
ExOtp.valid_hotp?(hotp, otp, 0) # Specify counter value
#=> true
```

### QR Code(Optional)

- Generate the provision URI for use with a QR code scanner built into MFA apps such as Google Authenticator.
- Generate the QR code using the `EQRCode` libraby, which is an optional dependency.
- Given a `totp` object and an `otp`, you can generate the QR code using:

```elixir

totp
|> ExOtp.provision_uri_totp(otp, "test:shubham@google.com",issuer_name: "test")
|> ExOtp.generate_qr_code("code.svg")
#=> 09:51:17.102 [info]  QR code written to file: code.svg
```

### Coverage

- Generate the coverage report using following mix task:
```elixir
MIX_ENV=test mix excoveralls
```

## Credits
- [PyOTP](https://github.com/pyauth/pyotp) - The API and implementation is largely based on PyOTP.
- [Nimble TOTP](https://github.com/dashbitco/nimble_totp) by Dashbit.
    - Generally, I used this library to check the correctness of my implementation, and also borrowed their implementation for generating the QR code :) 
    - Their library supports a few optional features, which are missing in `ex_otp` for now.
    - I also aim to add benchmarks tests comparing our libraries in the near future!

## License

Copyright 2022 Shubham Gupta

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.