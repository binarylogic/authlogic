source "https://rubygems.org"
gemspec :path => "./../.."

gem "activerecord", "~> 4.0.13"
gem "activesupport", "~> 4.0.13"
gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
gem 'sqlite3', :platforms => :ruby
