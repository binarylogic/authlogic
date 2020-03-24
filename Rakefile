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
  #
  # TODO: I had to temporarily disable warnings because TravisCI has a maximum
  # log length of 4MB and the following warning was printed thousands of times:
  #
  # > ../postgresql/database_statements.rb:24:
  # > warning: rb_tainted_str_new is deprecated and will be removed in Ruby 3.2.
  #
  test.ruby_opts += ["-W0"]
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[rubocop test]

require "coveralls/rake/task"
Coveralls::RakeTask.new
