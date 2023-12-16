# frozen_string_literal: true

require "English"
$LOAD_PATH.push File.expand_path("lib", __dir__)
require "authlogic/version"

::Gem::Specification.new do |s|
  s.name = "authlogic"
  s.version = ::Authlogic.gem_version.to_s
  s.platform = ::Gem::Platform::RUBY
  s.authors = [
    "Ben Johnson",
    "Tieg Zaharia",
    "Jared Beck"
  ]
  s.email = [
    "bjohnson@binarylogic.com",
    "tieg.zaharia@gmail.com",
    "jared@jaredbeck.com"
  ]
  s.homepage = "https://github.com/binarylogic/authlogic"
  s.summary = "An unobtrusive ruby authentication library based on ActiveRecord."
  s.license = "MIT"
  s.metadata = { "rubygems_mfa_required" => "true" }
  s.required_ruby_version = ">= 2.6.0"

  # See doc/rails_support_in_authlogic_5.0.md
  s.add_dependency "activemodel", [">= 5.2", "< 7.2"]
  s.add_dependency "activerecord", [">= 5.2", "< 7.2"]
  s.add_dependency "activesupport", [">= 5.2", "< 7.2"]
  s.add_dependency "request_store", "~> 1.0"
  s.add_development_dependency "bcrypt", "~> 3.1"
  s.add_development_dependency "byebug", "~> 10.0"
  s.add_development_dependency "coveralls", "~> 0.8.22"
  s.add_development_dependency "minitest", "< 5.19.0" # See https://github.com/binarylogic/authlogic/issues/766
  s.add_development_dependency "minitest-reporters", "~> 1.3"
  s.add_development_dependency "mysql2", "~> 0.5.2"
  s.add_development_dependency "pg", "~> 1.1.4"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rubocop", "~> 0.80.1"
  s.add_development_dependency "rubocop-performance", "~> 1.1"
  s.add_development_dependency "scrypt", ">= 1.2", "< 4.0"
  s.add_development_dependency "simplecov", "~> 0.16.1"
  s.add_development_dependency "simplecov-console", "~> 0.4.2"
  s.add_development_dependency "sqlite3", "~> 1.4.0"
  s.add_development_dependency "timecop", "~> 0.7"

  # To reduce gem size, only the minimum files are included.
  #
  # Tests are intentionally excluded. We only support our own test suite, we do
  # not have enough volunteers to support "in-situ" testing.
  s.files = `git ls-files -z`.split("\x0").select { |f|
    f.match(%r{^(LICENSE|lib|authlogic.gemspec)/})
  }
  s.test_files = [] # not packaged, see above
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
