# frozen_string_literal: true

require "rubygems"

# :nodoc:
module Authlogic
  # Returns a `::Gem::Version`, the version number of the authlogic gem.
  #
  # It is preferable for a library to provide a `gem_version` method, rather
  # than a `VERSION` string, because `::Gem::Version` is easier to use in a
  # comparison.
  #
  # We cannot return a frozen `Version`, because rubygems will try to modify it.
  # https://github.com/binarylogic/authlogic/pull/590
  #
  # Added in 4.0.0
  #
  # @api public
  def self.gem_version
    ::Gem::Version.new("6.1.0")
  end
end
