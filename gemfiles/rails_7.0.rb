# frozen_string_literal: true

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source "https://rubygems.org"
gemspec path: ".."

gem "activerecord", "~> 7.0.0"
gem "activesupport", "~> 7.0.0"
