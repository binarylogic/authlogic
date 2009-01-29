require 'rubygems'
require File.dirname(__FILE__) << "/lib/authlogic/version"
require 'echoe'
  
Echoe.new 'authlogic' do |p|
  p.version = Authlogic::Version::STRING
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.project = 'authlogic'
  p.summary = "A clean, simple, and unobtrusive ruby authentication solution."
  p.url = "http://github.com/binarylogic/authlogic"
  p.dependencies = %w(activesupport echoe)
  p.install_message = "BREAKS BACKWARDS COMPATIBILITY! This is only for those using I18n. If you were using the Authlogic configuration to implement I18n you need to update your configuration. A new cleaner approach has been implemented for I18n in Authlogic. See Authlogic::I18n for more details."
end