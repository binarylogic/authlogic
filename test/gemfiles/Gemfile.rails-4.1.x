source "https://rubygems.org"
gemspec :path => "./../.."

gem "activerecord", "~> 4.1.0"
gem "activesupport", "~> 4.1.0"
gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
gem 'sqlite3', :platforms => :ruby
