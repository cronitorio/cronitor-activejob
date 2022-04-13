# Cronitor::ActiveJob

[Cronitor](https://cronitor.io/) provides dead simple monitoring for cron jobs, daemons, queue workers, websites, APIs, and anything else that can send or receive an HTTP request. The Cronitor ActiveJob library provides a drop in integration for monitoring any ActiveJob job.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cronitor_activejob'
```

And then bundle:

    $ bundle


## Usage

Configure `cronitor` with an [API Key](https://cronitor.io/docs/api-overview) from [your settings](https://cronitor.io/settings). You can use ENV variables to configure Cronitor:

```sh
export CRONITOR_API_KEY='api_key_123'
export CRONITOR_ENVIRONMENT='development' #default: 'production'
```

Or declare the API key directly on the Cronitor module from within your application (e.g. with an initializer).

```ruby
require 'cronitor'
Cronitor.api_key = 'api_key_123'
Cronitor.environment = 'development' #default: 'production'
```


To monitor jobs include the module in your job class

```ruby
class MyJob < ApplicationJob
  include Cronitor::ActiveJob
end
```

When this job is invoked, Cronitor will send telemetry pings with a `key` matching the name of your job class (`MyJob` in the example above). If no monitor exists it will create one on the first event. You can configure rules at a later time via the Cronitor dashboard, API, or [YAML config](https://github.com/cronitorio/cronitor-ruby#configuring-monitors) file.

Optional: You can specify the monitor key directly using `cronitor_key`:

```ruby
class MyJob < ApplicationJob
  include Cronitor::ActiveJob
  cronitor_key 'abc123'

  def perform
  end
end
```


To disable Cronitor for a specific job you can set the following option:

```ruby
class MyJob < ApplicationJob
  include Cronitor::ActiveJob
  cronitor_disabled: true

  def perform
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cronitorio/cronitor-activejob. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
