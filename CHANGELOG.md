# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

* Breaking Changes
  * None
* Added
  * [#684](https://github.com/binarylogic/authlogic/pull/684) - Use cookies
    only when available. Support for `ActionController::API`
  * [#728](https://github.com/binarylogic/authlogic/pull/728) - Allow
    single_access_token to be supplied using Headers in addition to Params.
* Fixed
  * None

## 6.1.0 (2020-05-03)

* Breaking Changes
  * None
* Added
  * [#666](https://github.com/binarylogic/authlogic/pull/666) -
    Forwardported Authlogic::Session::Cookies.encrypt_cookie option
  * [#723](https://github.com/binarylogic/authlogic/pull/723) -
    Option to raise a `Authlogic::ModelSetupError` when your database is not
    configured correctly.
* Fixed
  * None

## 6.0.0 (2020-03-23)

* Breaking Changes, Major
  * There is no longer a default `crypto_provider`. We still recommend SCrypt,
    but don't want users of other providers to be forced to install it. You
    must now explicitly specify your `crypto_provider`, eg. in your `user.rb`.

        acts_as_authentic do |c|
          c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
        end

    To continue to use the `scrypt` gem, add it to your `Gemfile`.

        gem "scrypt", "~> 3.0"

* Breaking Changes, Minor
  * To set your crypto provider, you must use `crypto_provider=`, not
    `crypto_provider`. The arity of the later has changed from -1 (one optional
    arg) to 0 (no arguments).
* Added
  * [#702](https://github.com/binarylogic/authlogic/pull/702) - The ability to
    specify "None" as a valid SameSite attribute
* Fixed
  * [#686](https://github.com/binarylogic/authlogic/pull/686) - Respect
    the `log_in_after_create` setting when creating a new logged-out user
  * [#668](https://github.com/binarylogic/authlogic/pull/668) -
    BCrypt user forced to load SCrypt
  * [#697](https://github.com/binarylogic/authlogic/issues/697) - Add V2
    CryptoProviders for MD5 and SHA schemes that fix key stretching by hashing
    the byte digests instead of the hex strings representing those digests
* Dependencies
  * Drop support for ruby 2.3 (reached EOL on 2019-04-01)

## Previous major version

See eg. the `5-1-stable` branch

[1]: https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
