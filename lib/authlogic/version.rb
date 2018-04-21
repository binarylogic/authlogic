# frozen_string_literal: true

require "rubygems"

module Authlogic
  # Returns a `::Gem::Version`, the version number of the authlogic gem.
  #
  # It is preferable for a library to provide a `gem_version` method, rather
  # than a `VERSION` string, because `::Gem::Version` is easier to use in a
  # comparison.
  #
  # Perhaps surprisingly, we cannot return a frozen `Version`, because eg.
  # rubygems (currently) needs to be able to modify it.
  # https://github.com/binarylogic/authlogic/pull/590
  #
  # @api public
  def self.gem_version
    ::Gem::Version.new("4.0.1")
  end
end
