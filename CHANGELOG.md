# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

* Breaking Changes
  * None
* Added
  * [#666](https://github.com/binarylogic/authlogic/pull/666) -
    Forwardported Authlogic::Session::Cookies.encrypt_cookie option
* Fixed
  * None

## 5.1.0 (2020-03-23)

* Breaking Changes
  * None
* Added
  * [#703](https://github.com/binarylogic/authlogic/pull/703) - The ability to
    specify "None" as a valid SameSite attribute
* Fixed
  * None

## 5.0.4 (2019-09-11)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#681](https://github.com/binarylogic/authlogic/pull/681) -
    Delete unnecessary `AuthlogicLoadedTooLateError`

## 5.0.3 (2019-09-07)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#678](https://github.com/binarylogic/authlogic/pull/678) -
    Fix `ActionText` deprecation warning by lazily loading controller adapter

## 5.0.2 (2019-04-21)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#665](https://github.com/binarylogic/authlogic/pull/665) -
    Explicitly set case_sensitive: true for validates_uniqueness_of validation
    due to deprecation in Rails 6.0
  * [#659](https://github.com/binarylogic/authlogic/pull/659) -
    Fixed an issue affecting case-sensitive searches in MySQL

## 5.0.1 (2019-02-13)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#650](https://github.com/binarylogic/authlogic/pull/650) -
    rails 6.0.0.beta1 made a breaking change to case_insensitive_comparison

## 5.0.1 (2019-02-13)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#650](https://github.com/binarylogic/authlogic/pull/650) -
    rails 6.0.0.beta1 made a breaking change to case_insensitive_comparison

## 5.0.0 (2019-01-04)

* Breaking Changes
  * Likely to affect many people
    * [#629](https://github.com/binarylogic/authlogic/pull/629) -
      Drop validations deprecated in 4.4.0.
      * See [doc/use_normal_rails_validation.md][1]
      * [#640](https://github.com/binarylogic/authlogic/pull/640) -
        Drop `Authlogic::Regex`
    * [#628](https://github.com/binarylogic/authlogic/pull/628) -
      Drop `authenticates_many`, deprecated in 4.4.0
  * Likely to affect few people
    * [#617](https://github.com/binarylogic/authlogic/pull/617) -
      Drop AES-256 crypto provider, deprecated in 4.2.0
    * [#617](https://github.com/binarylogic/authlogic/pull/617) -
      Drop restful_authentication, deprecated in 4.1.0
  * Unlikely to affect anyone
    * [#647](https://github.com/binarylogic/authlogic/pull/647) -
      Drop the wordpress crypto provider, deprecated in 4.1.0
    * [#618](https://github.com/binarylogic/authlogic/pull/618) -
      Uses `frozen_string_literal`, so assume all strings returned are frozen
    * [#642](https://github.com/binarylogic/authlogic/pull/642) -
      The modules that were mixed into `Authlogic::Session::Base` have been
      inlined and deleted. This only affects you if you were re-opening
      ("monkey-patching") one of the deleted modules, in which case you can
      re-open `Base` instead.
    * [#648](https://github.com/binarylogic/authlogic/pull/648) -
      `Session::Base#credentials` now always returns a hash.
* Added
  * None
* Fixed
  * [#638](https://github.com/binarylogic/authlogic/pull/638) -
    Address Rails 5.1 changes to ActiveModel::Dirty
* Dependencies
  * [#632](https://github.com/binarylogic/authlogic/pull/632) -
    Add support for rails 6.0, drop support for rails < 5.2. See
    [doc/rails_support_in_authlogic_5.0.md](https://git.io/fpK7j) for details.
  * [#645](https://github.com/binarylogic/authlogic/pull/645) -
    Add support for ruby 2.6

## Previous major version

See eg. the `4-5-stable branch`

[1]: https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
