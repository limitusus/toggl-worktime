# Toggl::Worktime

This gem provides a command `toggl-worktime`, that summarises your Toggl time entries into working time chunks, which is useful for reporting your working hours.
You can easily report your working hours from its output.

Weekday

```console
$ toggle-worktime 6 12
Tomoya Kabe
worktime
2017-06-12 09:54:34 - 2017-06-12 12:40:45
2017-06-12 13:29:09 - 2017-06-12 19:23:23
```

Weekend

```console
$ toggle-worktime 6 10
Tomoya Kabe
worktime
nil - nil
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toggl-worktime'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toggl-worktime

## Usage

### Toggl API Token

Write your Toggl API token on to `~/.toggl`.

```
abcdef0123456789
```

You can get your API token from Toggl at your profile settings page.

### Just run

```console
toggl-worktime MONTH DAY
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/limitusus/toggl-worktime. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Toggl::Worktime project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/limitusus/toggl-worktime/blob/master/CODE_OF_CONDUCT.md).