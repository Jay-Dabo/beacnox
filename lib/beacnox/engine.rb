require "action_view/log_subscriber"
require_relative "rails/middleware"
require_relative "models/collection"
require_relative "instrument/metrics_collector"
require_relative "extensions/resources_monitor"

module Beacnox
  class Engine < ::Rails::Engine
    isolate_namespace Beacnox

    initializer "beacnox.resource_monitor" do
      # check required gems are available
      Beacnox._resource_monitor_enabled = !!(defined?(Sys::Filesystem) && defined?(Sys::CPU) && defined?(GetProcessMem))

      next unless Beacnox.enabled
      next if $beacnox_running_mode == :console # rubocop:disable Style/GlobalVars

      # start monitoring
      Beacnox._resource_monitor = Beacnox::Extensions::ResourceMonitor.new(
        ENV["RAILS_PERFORMANCE_SERVER_CONTEXT"].presence || "rails",
        ENV["RAILS_PERFORMANCE_SERVER_ROLE"].presence || "web"
      )
    end

    initializer "beacnox.middleware" do |app|
      next unless Beacnox.enabled

      app.middleware.insert_after ActionDispatch::Executor, Beacnox::Rails::Middleware
      # look like it works in reverse order?
      app.middleware.insert_before Beacnox::Rails::Middleware, Beacnox::Rails::MiddlewareTraceStorerAndCleanup

      if defined?(::Sidekiq)
        require_relative "gems/sidekiq_ext"

        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add Beacnox::Gems::SidekiqExt
          end

          config.on(:startup) do
            if $beacnox_running_mode != :console # rubocop:disable Style/GlobalVars
              # stop web monitoring
              # when we run sidekiq it also starts web monitoring (see above)
              Beacnox._resource_monitor.stop_monitoring
              Beacnox._resource_monitor = nil
              # start background monitoring
              Beacnox._resource_monitor = Beacnox::Extensions::ResourceMonitor.new(
                ENV["RAILS_PERFORMANCE_SERVER_CONTEXT"].presence || "sidekiq",
                ENV["RAILS_PERFORMANCE_SERVER_ROLE"].presence || "background"
              )
            end
          end
        end
      end

      if defined?(::Grape)
        require_relative "gems/grape_ext"
        Beacnox::Gems::GrapeExt.init
      end

      if defined?(::Delayed::Job)
        require_relative "gems/delayed_job_ext"
        Beacnox::Gems::DelayedJobExt.init
      end
    end

    initializer :configure_metrics, after: :initialize_logger do
      next unless Beacnox.enabled

      ActiveSupport::Notifications.subscribe(
        "process_action.action_controller",
        Beacnox::Instrument::MetricsCollector.new
      )
    end

    config.after_initialize do
      next unless Beacnox.enabled

      ActionView::LogSubscriber.send :prepend, Beacnox::Extensions::View
      ActiveRecord::LogSubscriber.send :prepend, Beacnox::Extensions::Db if defined?(ActiveRecord)

      if defined?(::Rake::Task) && Beacnox.include_rake_tasks
        require_relative "gems/rake_ext"
        Beacnox::Gems::RakeExt.init
      end
    end

    if defined?(::Rails::Console)
      $beacnox_running_mode = :console # rubocop:disable Style/GlobalVars
    end
  end
end
