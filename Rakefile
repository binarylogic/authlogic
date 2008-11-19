require 'rubygems'
require File.dirname(__FILE__) << "/lib/authlogic/version"

begin
  require 'echoe'
  
  Echoe.new 'authlogic' do |p|
    p.version = Authlogic::Version::STRING
    p.author = "Ben Johnson of Binary Logic"
    p.email  = 'bjohnson@binarylogic.com'
    p.project = 'authlogic'
    p.summary = "A clean, simple, and unobtrusive ruby authentication solution."
    p.url = "http://github.com/binarylogic/authlogic"
    p.dependencies = %w(activesupport)
  end
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."

  desc 'No effect.'
  task :default; end

  # if you still want tests when Echoe is not present
  desc 'Run the test suite.'
  task :test do
     system "ruby -Ibin:lib:test some_tests_test.rb" # or whatever
  end
end