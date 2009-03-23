ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/authlogic/version"

Hoe.new("Authlogic", Authlogic::Version::STRING) do |p|
  p.name = "authlogic"
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.summary = "A clean, simple, and unobtrusive ruby authentication solution."
  p.description = "A clean, simple, and unobtrusive ruby authentication solution."
  p.url = "http://github.com/binarylogic/authlogic"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(activesupport)
  p.post_install_message = "Version 2.0 introduces some changes that break backwards compatibility. The big change is how acts_as_authentic accepts configuration options. Instead of a hash, it now accepts a block: acts_as_authentic { |c| c.my_config_option = my_value}. See the docs for more details."
end