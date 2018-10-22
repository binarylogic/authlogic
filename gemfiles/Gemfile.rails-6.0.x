source "https://rubygems.org"
gemspec :path => ".."

# TODO: Use actual version number
gem "activerecord", github: 'rails/rails'
gem "activesupport", github: 'rails/rails'
gem 'sqlite3', :platforms => :ruby
