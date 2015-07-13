# Changelog

## Unreleased

* changes
  * ...

## 3.4.6 2015

* changes
  * add Regex.email_nonascii for validation of emails w/unicode (@rchekaluk)
  * allow scrypt 2.x (@jaredbeck)

## 3.4.5 2015-03-01

* changes
  * security-hardening fix and cleanup in persistence_token lookup
  * security-hardening fix in perishable_token lookup (thx @tomekr)

## 3.4.4 2014-12-23

* changes
  * extract rw_config into an Authlogic::Config module
  * improved the way config changes are made in tests
  * fix for Rails 4.2 by extending ActiveModel

## 3.4.3 2014-10-08

* changes
  * backfill CHANGELOG
  * better compatibility with jruby (thx @petergoldstein)
  * added scrypt as a dependency
  * cleanup some code (thx @roryokane)
  * reference 'bcrypt' gem instead of 'bcrypt-ruby' (thx @roryokane)
  * fixed typo (thx @chamini2)
  * fixed magic column validations for Rails 4.2 (thx @tom-kuca)

## 3.4.2 2014-04-28

* changes
  * fixed the missing scrypt/bcrypt gem errors introduced in 3.4.1
  * implemented autoloading for providers
  * added longer subdomain support in email regex

## 3.4.1 2014-04-04

* changes
  * undid an accidental revert of some code

## 3.4.0 2014-03-03

* new
  * added cookie signing
  * added request store for better concurency for threaded environments

* changes
  * BREAKING CHANGE: made scrypt the default crypto provider from SHA512 (https://github.com/binarylogic/authlogic#upgrading-to-authlogic-340)
  * ditched appraisal
  * officially support rails 4 (still supporting rails 3)
  * improved find_with_case default performance
  * added a rack adapter for Rack middleware support
  * added travis ci support

## 3.3.0 2014-04-04

* changes
  * added safeguard against a sqli that was also fixed in rails 3.2.10/3.1.9/3.0.18
  * imposed the bcrypt gem's mincost
  * removed shoulda macros

## 3.2.0 2012-12-07

* new
  * scrypt support

* changes
  * moved back to LOWER for find_with_case ci lookups

## 3.1.3 2012-06-13

* changes
  * removed jeweler

## 3.1.2 2012-06-01

* changes
  * mostly test fixes

## 3.1.1 2012-06-01

* changes
  * mostly doc fixes

## 3.1.0 2011-10-19

* changes
  * mostly small bug fixes

## 3.0.3 2011-05-17

* changes
  * rails 3.1 support

* new
  * http auth support

## 3.0.2 2011-04-30

* changes
  * doc fixes

## 3.0.1 2011-04-30

* changes
  * switch from LOWER to LIKE for find_with_case ci lookups

## 3.0.0 2011-04-30

* new
  * ssl cookie support
  * httponly cookie support
  * added a session generator

* changes
  * rails 3 support
  * ruby 1.9.2 support
