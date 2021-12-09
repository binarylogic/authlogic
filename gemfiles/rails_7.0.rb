# frozen_string_literal: true

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source "https://rubygems.org"
gemspec path: ".."

# For some reason, Rails 7.0.0.rc1 is tagged as 7.1.0.alpha
gem "activerecord", "~> 7.1.0.alpha", github: "rails/rails", branch: "main"
gem "activesupport", "~> 7.1.0.alpha", github: "rails/rails", branch: "main"
