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
  s.homepage = "http://github.com/binarylogic/authlogic"
  s.summary = "A clean, simple, and unobtrusive ruby authentication solution."
  s.license = "MIT"

  s.required_ruby_version = ">= 2.3.0"
  s.add_dependency "activerecord", [">= 4.2", "< 5.3"]
  s.add_dependency "activesupport", [">= 4.2", "< 5.3"]
  s.add_dependency "request_store", "~> 1.0"
  s.add_dependency "scrypt", ">= 1.2", "< 4.0"
  s.add_development_dependency "bcrypt", "~> 3.1"
  s.add_development_dependency "byebug", "~> 10.0"
  s.add_development_dependency "minitest-reporters", "~> 1.3"
  s.add_development_dependency "rubocop", "~> 0.58.1"
  s.add_development_dependency "timecop", "~> 0.7"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
