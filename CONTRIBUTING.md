### Testing

Tests can be ran against different versions of Rails like so:

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle install
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle exec rake test
```

### Linting

Running `rake test` also runs a linter, rubocop. Contributions must pass both
the linter and the tests. The linter can be run on its own.

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle exec rubocop
```
