# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "authlogic"
  s.version     = "3.1.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/authlogic"
  s.summary     = %q{A clean, simple, and unobtrusive ruby authentication solution.}
  s.description = %q{A clean, simple, and unobtrusive ruby authentication solution.}

  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bcrypt-ruby'
  s.add_development_dependency 'sqlite3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end