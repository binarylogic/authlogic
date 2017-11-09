$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "authlogic"
  s.version     = "3.5.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/authlogic"
  s.summary     = 'A clean, simple, and unobtrusive ruby authentication solution.'
  s.description = 'A clean, simple, and unobtrusive ruby authentication solution.'
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.1.0'
  s.add_dependency 'activerecord', ['>= 4.2', '< 5.2']
  s.add_dependency 'activesupport', ['>= 4.2', '< 5.2']
  s.add_dependency 'request_store', '~> 1.0'
  s.add_dependency 'scrypt', '>= 1.2', '< 4.0'
  s.add_development_dependency 'bcrypt', '~> 3.1'

  # byebug 9.1 drops support for ruby 2.1, so we must stay < 9.1 for now.
  # We are currently discussing the dropping ruby 2.1:
  # https://github.com/binarylogic/authlogic/pull/572
  s.add_development_dependency 'byebug', '~> 9.0.6'

  s.add_development_dependency 'rubocop', '~> 0.51.0'
  s.add_development_dependency 'timecop', '~> 0.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
