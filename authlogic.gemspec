# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "authlogic"
  s.version     = "3.6.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/authlogic"
  s.summary     = 'A clean, simple, and unobtrusive ruby authentication solution.'
  s.description = 'A clean, simple, and unobtrusive ruby authentication solution.'

  s.license = 'MIT'

  s.add_dependency 'activerecord', ['>= 3.2', '< 5.3']
  s.add_dependency 'activesupport', ['>= 3.2', '< 5.3']
  s.add_dependency 'request_store', '~> 1.0'
  s.add_dependency 'scrypt', '>= 1.2', '< 4.0'
  s.add_development_dependency 'bcrypt', '~> 3.1'
  s.add_development_dependency 'timecop', '~> 0.7'
  s.add_development_dependency 'rubocop', '~> 0.41.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
