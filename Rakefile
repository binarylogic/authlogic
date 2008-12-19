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
    p.dependencies = %w(activesupport echoe)
  end
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
end