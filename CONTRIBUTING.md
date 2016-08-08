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

Please use github issues for reproducible, minimal bug reports.

### Usage Questions

Please use stackoverflow for usage questions.

## Development

### Testing

Tests can be ran against different versions of Rails like so:

```
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle install
BUNDLE_GEMFILE=test/gemfiles/Gemfile.rails-3.2.x bundle exec rake
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
