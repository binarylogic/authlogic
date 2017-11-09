require 'rubygems'
require 'bundler'

Bundler.setup

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false

  # Set interpreter warning level to 1 (medium). Level 2 produces hundreds of warnings
  # about uninitialized instance variables.
  # TODO: Find a good way to deal with the level 2 warnings.
  test.ruby_opts += ["-W1"]
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: [:rubocop, :test]
