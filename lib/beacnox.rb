require "redis"
require "browser"
require "active_support/core_ext/integer"
require_relative "beacnox/version"
require_relative "beacnox/rails/query_builder"
require_relative "beacnox/rails/middleware"
require_relative "beacnox/models/base_record"
require_relative "beacnox/models/request_record"
require_relative "beacnox/models/sidekiq_record"
require_relative "beacnox/models/delayed_job_record"
require_relative "beacnox/models/grape_record"
require_relative "beacnox/models/trace_record"
require_relative "beacnox/models/rake_record"
require_relative "beacnox/models/resource_record"
require_relative "beacnox/models/custom_record"
require_relative "beacnox/data_source"
require_relative "beacnox/utils"
require_relative "beacnox/reports/base_report"
require_relative "beacnox/reports/requests_report"
require_relative "beacnox/reports/crash_report"
require_relative "beacnox/reports/response_time_report"
require_relative "beacnox/reports/throughput_report"
require_relative "beacnox/reports/recent_requests_report"
require_relative "beacnox/reports/slow_requests_report"
require_relative "beacnox/reports/breakdown_report"
require_relative "beacnox/reports/trace_report"
require_relative "beacnox/reports/percentile_report"
require_relative "beacnox/reports/resources_report"
require_relative "beacnox/extensions/trace"
require_relative "beacnox/thread/current_request"

module Beacnox
  FORMAT = "%Y%m%dT%H%M"

  mattr_accessor :redis
  @@redis = Redis.new

  mattr_accessor :duration
  @@duration = 4.hours

  mattr_accessor :recent_requests_time_window
  @@recent_requests_time_window = 60.minutes

  mattr_accessor :recent_requests_limit
  @@recent_requests_limit = nil

  mattr_accessor :slow_requests_time_window
  @@slow_requests_time_window = 4.hours

  mattr_accessor :slow_requests_limit
  @@recent_requests_limit = 500

  mattr_accessor :slow_requests_threshold
  @@slow_requests_threshold = 500

  mattr_accessor :debug
  @@debug = false

  mattr_accessor :enabled
  @@enabled = true

  # default path where to mount gem
  mattr_accessor :mount_at
  @@mount_at = "/performance"

  # Enable http basic authentication
  mattr_accessor :http_basic_authentication_enabled
  @@http_basic_authentication_enabled = true

  # Enable http basic authentication
  mattr_accessor :http_basic_authentication_user_name
  @@http_basic_authentication_user_name = "beacnox-admin"

  # Enable http basic authentication
  mattr_accessor :http_basic_authentication_password
  @@http_basic_authentication_password = "@#</BeacnoxPassword>.1234"

  # If you want to enable access by specific conditions
  mattr_accessor :verify_access_proc
  @@verify_access_proc = proc { |controller| true }

  mattr_reader :ignored_endpoints
  def self.ignored_endpoints=(endpoints)
    @@ignored_endpoints = Set.new(endpoints)
  end
  @@ignored_endpoints = []

  mattr_reader :ignored_paths
  def self.ignored_paths=(paths)
    @@ignored_paths = Set.new(paths)
  end
  @@ignored_paths = []

  # skip requests if it's inside Beacnox view
  mattr_accessor :skip
  @@skip = false

  # config home button link
  mattr_accessor :home_link
  @@home_link = "/"

  # skip performance tracking for these rake tasks
  mattr_accessor :skipable_rake_tasks
  @@skipable_rake_tasks = []

  # add custom payload to the request
  mattr_accessor :custom_data_proc
  @@custom_data_proc = nil

  # include rake tasks
  mattr_accessor :include_rake_tasks
  @@include_rake_tasks = false

  # include custom events
  mattr_accessor :include_custom_events
  @@include_custom_events = true

  # Trace details view configuration
  mattr_accessor :ignore_trace_headers
  @@ignore_trace_headers = ["datetimei"]

  # System monitor duration (expiration time)
  mattr_accessor :system_monitor_duration
  @@system_monitor_duration = 24.hours

  # -- internal usage --
  #
  #
  # to store the resource monitor instance
  mattr_accessor :_resource_monitor
  @@_resource_monitor = nil

  # to check if we are running in console mode
  mattr_accessor :_running_mode
  @@_running_mode = nil

  # by default we don't want to monitor resources, but we can enable it by adding required gems
  mattr_accessor :_resource_monitor_enabled
  @@_resource_monitor_enabled = false

  def self.setup
    yield(self)
  end

  def self.log(message)
    return unless Beacnox.debug

    if ::Rails.logger
      # puts(message)
      ::Rails.logger.debug(message)
    else
      puts(message)
    end
  end
end

require "beacnox/engine"

require_relative "beacnox/gems/custom_ext"
Beacnox.send :extend, Beacnox::Gems::CustomExtension
