# frozen_string_literal: true

source "https://rubygems.org"
gemspec path: ".."

# Rails 6 beta 1 has been released, so you might expect us to use exactly that
# version here, but it is still in flux, so we may continue using git for a
# while, maybe until RC 1 is released.
gem "activerecord", github: "rails/rails", ref: "ebdaa04"
gem "activesupport", github: "rails/rails", ref: "ebdaa04"
gem "sqlite3", platforms: :ruby
