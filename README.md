# Beacnox

A self-hosted dashboard to monitor the performance of your Ruby on Rails applications.

This is a **simple and free alternative** to the New Relic APM, Datadog or other similar services.

![Demo](docs/beacnox.gif)

This comes with P50 (50th Percentile), P90 (90th Percentile), P99 (99th Percentile), throughput, and more is available.

![Home](docs/beacnox_updated_home.png)

Detailed p50, p90, p99 response time information.

![Home](docs/beacnox_recent_requests.png)

(more screenshots below)

It allows you to track:

- real-time monitoring on the Recent tab
- see your p50, p90, p99 response time
- monitor system resources (CPU, memory, disk)
- monitor slow requests
- throughput report (see amount of RPM (requests per minute))
- an average response time
- the slowest controllers & actions
- total duration of time spent per request, views rendering, DB
- SQL queries, rendering logs in "Recent Requests" section
- simple 500-crashes reports
- Sidekiq jobs
- Delayed Job jobs
- Grape API inside Rails app
- Rake tasks performance
- Custom events wrapped with `Beacnox.measure do .. end` block
- works with Rails 4.2+ (and probably 4.1, 4.0 too) and Ruby 2.2+

All data are stored in `local` Redis and not sent to any 3rd party servers.

## Production

Gem is production-ready. At least on my 2 applications with ~800 unique users per day it works perfectly.

Just don't forget to protect performance dashboard with http basic auth or check of current_user.

## Usage

```
1. Add gem to the Gemfile (in appropriate group if needed)
2. Start rails server
3. Make a few requests to your app
4. open localhost:3000/performance
5. Tune the configuration and deploy to production
```

Default configuration is listed below. But you can override it.

Create `config/initializers/beacnox.rb` in your app:

```ruby
Beacnox.setup do |config|
  config.redis    = Redis.new(url: ENV["REDIS_URL"].presence || "redis://127.0.0.1:6379/0") # or Redis::Namespace.new("beacnox", redis: Redis.new), see below in README
  config.duration = 4.hours

  config.debug    = false # currently not used>
  config.enabled  = true

  # configure Recent tab (time window and limit of requests)
  # config.recent_requests_time_window = 60.minutes
  # config.recent_requests_limit = nil # or 1000

  # configure Slow Requests tab (time window, limit of requests and threshold)
  # config.slow_requests_time_window = 4.hours # time window for slow requests
  # config.slow_requests_limit = 500 # number of max rows
  # config.slow_requests_threshold = 500 # number of ms

  # default path where to mount gem,
  # alternatively you can mount the Beacnox::Engine in your routes.rb
  config.mount_at = '/performance'

  # if you need an additional rules to check user permissions
  config.verify_access_proc = proc { |controller| true }
  # for example when you have `current_user`
  # config.verify_access_proc = proc { |controller| controller.current_user && controller.current_user.admin? }

  # You can ignore endpoints with Rails standard notation controller#action
  # config.ignored_endpoints = ['HomeController#contact']

  # You can ignore request paths by specifying the beginning of the path.
  # For example, all routes starting with '/admin' can be ignored:
  config.ignored_paths = ['/performance', '/admin']

  # store custom data for the request
  # config.custom_data_proc = proc do |env|
  #   request = Rack::Request.new(env)
  #   {
  #     email: request.env['warden'].user&.email, # if you are using Devise for example
  #     user_agent: request.env['HTTP_USER_AGENT']
  #   }
  # end

  # config home button link
  config.home_link = '/'

  # To skip some Rake tasks from monitoring
  config.skipable_rake_tasks = ['webpacker:compile']

  # To monitor rake tasks performance, you need to include rake tasks
  # config.include_rake_tasks = false

  # To monitor custom events with `Beacnox.measure` block
  # config.include_custom_events = true

  # To monitor system resources (CPU, memory, disk)
  # to enabled add required gems (see README)
  # config.system_monitor_duration = 24.hours
end if defined?(Beacnox)
```

Additionally you might need to configure app time zone. You can do it in `config/application.rb`:

```ruby
config.time_zone = 'Eastern Time (US & Canada)'
```

Gem will present charts/tables in the app timezone. If it's not set, it will use UTC.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beacnox'

# or

group :development, :production do
  gem 'beacnox'
end
```

And then execute:

```bash
$ bundle
```

Create default configuration file:

```bash
$ rails generate beacnox:install
```

Have a look at `config/initializers/beacnox.rb` and adjust the configuration to your needs.

You must also have installed Redis server, because this gem is storing data into it.

After installation and configuration, start your Rails application, make a few requests, and open `https://localhost:3000/performance` URL.

### Alternative: Mounting the engine yourself

If you, for whatever reason (company policy, devise, ...) need to mount Beacnox yourself, feel free to do so by using the following snippet as inspiration.
You can skip the `mount_at` and `http_basic_authentication_*` configurations then, if you like.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  ...
  # example for usage with Devise
  authenticate :user, -> (user) { user.admin? } do
    mount Beacnox::Engine, at: 'performance'
  end
end
```

### Custom data

You need to configure `config.custom_data_proc`. And you can capture current_user, HTTP User Agent, etc. This proc is executed inside middleware, and you have access to Rack "env".

![Custom Data](docs/custom_data.png)


### Server Monitoring

![Server Monitoring](docs/beacnox_cpu_memory_storage.png)

You can monitor system resources (CPU, memory, disk) by adding a gem to your Gemfile:

```ruby
gem "sys-filesystem"
gem "sys-cpu"
gem "get_process_mem"
```

Once you add these gems, it will track and show you the system resources on the dashboard.

If you have multiple servers running the same app, it will use store metrics per server. You can configure the the env variable ENV["BEACNOX_SERVER_ID"] or using `hostname` command.

Basically using this code:

```ruby
      def server_id
        @server_id ||= ENV["BEACNOX_SERVER_ID"] || `hostname`.strip
      end
```

For Kamal for example:

```yaml
env:
  clear:
    BEACNOX_SERVER_ID: "server"
```

You can also specifify custom "context" and "role" for monitoring, by changing the env variables:

```ruby
Beacnox::Extensions::ResourceMonitor.new(
  ENV["BEACNOX_SERVER_CONTEXT"].presence || "rails",
  ENV["BEACNOX_SERVER_ROLE"].presence || "web"
)
```

More information here: `lib/beacnox/engine.rb`.

PS: right now it can only distinguish between web app servers and the sidekiq servers.

### Custom events

```ruby
Beacnox.measure("some label", "some namespace") do
   # your code
end
```

## Using with Rails Namespace

If you want to use Redis namespace (for example when you have multiple apps running on the same server), you can configure it like this:

```ruby
  config.redis = Redis::Namespace.new("#{Rails.env}-beacnox", redis: Redis.new(url: ENV["REDIS_URL"].presence || "redis://127.0.0.1:6379/0"))
```

and add a gem dependency to the Gemfile:

```ruby
gem 'redis-namespace'
```

## How it works

![Schema](docs/beacnox.png)

In addition it's wrapping gems internal methods and collecting performance information. See `./lib/beacnox/gems/*` for more information.

## Limitations

- it doesn't track params of POST/PUT requests
- it doesn't track Redis/ElasticSearch or other apps
- it can't compare historical data
- depending on your load you may need to reduce time of for how long you store data, because all calculations are done in memory and it could take some time for high-load apps

## Redis

Gem is using Redis. This is the only one dependency.

All information is stored into Redis. The default expiration time is set to `config.duration` from the configuration.

## Development & Testing

Just clone the repo, setup dummy app (`rails db:migrate`).

After this:

- rails s
- rake test

If you need quickly clear Redis data, you can use `rails runner 'Beacnox.redis.flushdb'`.

Like a regular web development.

Please note that to simplify integration with other apps all CSS/JS are bundled inside, and delivered in body of the request. This is to avoid integration with assets pipeline or webpacker.

For UI changes you need to use Bulma CSS (https://bulma.io/documentation).

## Why

The idea of this gem grew from curiosity how many RPM my app receiving per day. Later it evolved to something more powerful.

[//]: # (## TODO)

[//]: # ()
[//]: # (- documentation in Readme?)

[//]: # (- capture stacktrace of 500 errors and show in side panel)

[//]: # (- time/zone config?)

[//]: # (- connected charts on dashboard, when zoom, when hover?)

[//]: # (- ability to zoom to see requests withing specific datetime range)

[//]: # (- better hints?)

[//]: # (- export to csv)

[//]: # (- better stats tooltip, do not show if nothing to show)

[//]: # (- dark mode toggle? save to the cookies?)

[//]: # (- integration with elastic search? or other?)

[//]: # (- monitor active job?)

[//]: # (- better logo?)

[//]: # (- number of requests last 24 hours, hour, etc.)

[//]: # (- collect deprecation.rails)

[//]: # (- fix misspellings?)

[//]: # (- show "loading banner" until jquery is loaded?)

[//]: # (- better UI on smaller screens? Recent requests when URL's are long? Truncate with CSS?)

[//]: # (- rules for highlighting durations? how many ms to show warning, alert)

[//]: # (- elastic search)

[//]: # (- searchkiq)

[//]: # (- sinatra?)

[//]: # (- tests to check what is actually stored in redis db after request)

[//]: # (- upgrade bulma)

## Contributing

You are welcome to contribute. We have a big list of TODO.

If "schema" how records are stored i Redis is changed, and this is a breaking change, update: `Beacnox::SCHEMA` to a newer value.