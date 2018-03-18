# frozen_string_literal: true

require "rubygems"

module Authlogic
  # Returns a `::Gem::Version`, the version number of the authlogic gem.
  #
  # It is preferable for a library to provide a `gem_version` method, rather
  # than a `VERSION` string, because `::Gem::Version` is easier to use in a
  # comparison.
  #
  # @api public
  def self.gem_version
    ::Gem::Version.new('3.8.0')
  end
end
