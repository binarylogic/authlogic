# frozen_string_literal: true

require "rubygems"
require "bundler"

Bundler.setup

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = false

  # Set interpreter warning level to 2 (verbose)
  test.ruby_opts += [format("-W%d", 2)]
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[rubocop test]

require "coveralls/rake/task"
Coveralls::RakeTask.new
