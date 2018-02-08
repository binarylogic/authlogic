# Contributing to Authlogic

## Issues

### Security Issues

**Do not disclose security issues in public.** Instead, please email:

```
Ben Johnson <bjohnson@binarylogic.com>,
Tieg Zaharia <tieg.zaharia@gmail.com>
Jared Beck <jared@jaredbeck.com>
```

We will review security issues promptly.

### Non-Security Issues

Please use github issues only for bug reports and feature requests.

### Usage Questions

Please ask usage questions on
[stackoverflow](http://stackoverflow.com/questions/tagged/authlogic).

## Development

Most local development should be done using the oldest supported version of
ruby. See `required_ruby_version` in the gemspec.

### Testing

Tests can be run against different versions of Rails like so:

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-4.2.x bundle install
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-4.2.x bundle exec rake
```

To run a single test:

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-4.2.x \
  bundle exec ruby –I test path/to/test.rb
```

### Linting

Running `rake` also runs a linter, rubocop. Contributions must pass both
the linter and the tests. The linter can be run on its own.

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle exec rubocop
```

To run the tests without linting, use `rake test`.

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle exec rake test
```

### Release

1. Update version number in gemspec
1. Add release date to changelog entry
1. Commit
1. git tag -a -m "v3.6.0" "v3.6.0"
1. git push --tags origin 3-stable # or whatever branch
1. gem build authlogic.gemspec
1. gem push authlogic-3.6.0
