require 'rubygems'
require 'rake'

begin
  require 'bcrypt'
rescue LoadError
  raise "sudo gem install bcrypt-ruby"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "authlogic"
    gem.summary = "A clean, simple, and unobtrusive ruby authentication solution."
    gem.email = "bjohnson@binarylogic.com"
    gem.homepage = "http://github.com/binarylogic/authlogic"
    gem.authors = ["Ben Johnson of Binary Logic"]
    gem.add_dependency "activesupport"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test
