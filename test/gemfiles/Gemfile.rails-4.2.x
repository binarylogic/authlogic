source "https://rubygems.org"
gemspec :path => "./../.."

gem "activerecord", "~> 4.2.8.rc1"
gem "activesupport", "~> 4.2.8.rc1"
gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
gem 'sqlite3', :platforms => :ruby
