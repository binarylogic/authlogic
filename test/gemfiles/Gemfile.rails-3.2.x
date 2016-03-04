source "https://rubygems.org"
gemspec :path => "./../.."

gem "activerecord", "3.2.22"
gem "activesupport", "3.2.22"
gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
gem 'sqlite3', :platforms => :ruby