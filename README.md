# Toggl::Worktime

This gem provides a command `toggl-worktime`, that summarises your Toggl time entries into working time chunks, which is useful for reporting your working hours.
You can easily report your working hours from its output.

Weekday

```console
$ toggl-worktime 6 12
Tomoya Kabe
worktime
2017-06-12 09:54:34 - 2017-06-12 12:40:45
2017-06-12 13:29:09 - 2017-06-12 19:23:23
```

or you can specify year (default is "this" year)

```console
$ toggl-worktime 2017 6 12
Tomoya Kabe
worktime
2017-06-12 09:54:34 - 2017-06-12 12:40:45
2017-06-12 13:29:09 - 2017-06-12 19:23:23
```


Weekend

```console
$ toggl-worktime 6 10
Tomoya Kabe
worktime
nil - nil
```

## Calendar mode

You can see your monthly worktime in calendar view

```console
$ toggl-worktime --calendar 2021 1
┌────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬────────┐
│Sun     │Mon              │Tue              │Wed              │Thu              │Fri              │Sat     │
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│        │                 │                 │                 │                 │Day: 1           │Day: 2  │
│        │                 │                 │                 │                 │-                │-       │
│        │                 │                 │                 │                 │00:00:00         │00:00:00│
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│Day: 3  │Day: 4           │Day: 5           │Day: 6           │Day: 7           │Day: 8           │Day: 9  │
│-       │-                │10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│-       │
│00:00:00│00:00:00         │07:00:00         │07:00:00         │07:00:00         │07:00:00         │00:00:00│
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│Day: 10 │Day: 11          │Day: 12          │Day: 13          │Day: 14          │Day: 15          │Day: 16 │
│-       │-                │10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│-       │
│00:00:00│00:00:00         │07:00:00         │07:00:00         │07:00:00         │07:00:00         │00:00:00│
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│Day: 17 │Day: 18          │Day: 19          │Day: 20          │Day: 21          │Day: 22          │Day: 23 │
│-       │10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│-       │
│00:00:00│07:00:00         │07:00:00         │07:00:00         │07:00:00         │07:00:00         │00:00:00│
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│Day: 24 │Day: 25          │Day: 26          │Day: 27          │Day: 28          │Day: 29          │Day: 30 │
│-       │10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│10:00:00-18:00:00│-       │
│00:00:00│07:00:00         │07:00:00         │07:00:00         │07:00:00         │07:00:00         │00:00:00│
├────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼────────┤
│Day: 31 │                 │                 │                 │                 │                 │        │
│-       │                 │                 │                 │                 │                 │        │
│00:00:00│                 │                 │                 │                 │                 │        │
└────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴────────┘
```

You can change the beginning day of the week with `-b` option:

```console
$ toggl-worktime --calendar 2021 1 -b Mon
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

NOTE: as of togglv8 v1.2.1, `.toggl` file **MUST NOT** end with a newline (`\010` or LF).
The recommended way to create the file is `echo -n 'YOUR_TOGGL_API_TOKEN' > ~/.toggl`.
This issue [will be fixed in the next togglv8 release](https://github.com/kanet77/togglv8/pull/21).

### Configuration

Place configuration file in `~/.toggl_worktime`.
Or you can specify your favorite path with `-c CONFIG` option.

```
# -*- yaml -*-

# working time interval within <working_interval_min> minutes is ignored
working_interval_min: 10
# Split the day at <day_begin_hour> o'clock
day_begin_hour: 6
# Timezone
timezone: Asia/Tokyo

# Time entries which match the condition below will not be counted as working time
# Multiple conditions can be specified as an array in top level,
# multiple keys (only "tags" for now) can be specified as hash keys in a condition,
# and multiple values can be specifeid as an array.
# Array conditions will be treated as "OR"
# Hash conditions will be treated as "AND"
ignore_conditions:
  - tags:
      - vacation
```

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
