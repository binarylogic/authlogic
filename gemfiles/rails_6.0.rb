# frozen_string_literal: true

source "https://rubygems.org"
gemspec path: ".."

# TODO: Use actual version number
gem "activemodel", github: "rails/rails"
gem "activerecord", github: "rails/rails"
gem "activesupport", github: "rails/rails"
gem "sqlite3", platforms: :ruby
