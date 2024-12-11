require_relative "base_controller"

module Beacnox
  class BeacnoxController < Beacnox::BaseController
    protect_from_forgery except: :recent

    if Beacnox.enabled
      def index
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db

        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Beacnox::Reports::ResponseTimeReport.new(db).data
        @percentile_report_data = Beacnox::Reports::PercentileReport.new(db).data
      end

      def resources
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :resources, days: Beacnox::Utils.days(Beacnox.system_monitor_duration))
        db = @datasource.db

        @resources_report = Beacnox::Reports::ResourcesReport.new(db)
      end

      def summary
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db

        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Beacnox::Reports::ResponseTimeReport.new(db).data
        @data = Beacnox::Reports::BreakdownReport.new(db, title: "Requests").data
        respond_to do |format|
          format.js {}
          format.any do
            render plain: "Doesn't open in new window. Wait until full page load."
          end
        end
      end

      def trace
        @record = Beacnox::Models::RequestRecord.find_by(request_id: params[:id])
        @data = Beacnox::Reports::TraceReport.new(request_id: params[:id]).data
        respond_to do |format|
          format.js {}
          format.any do
            render plain: "Doesn't open in new window. Wait until full page load."
          end
        end
      end

      def crashes
        @datasource = Beacnox::DataSource.new(**prepare_query({status_eq: 500}), type: :requests)
        db = @datasource.db
        @data = Beacnox::Reports::CrashReport.new(db).data

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv "error_report", @data
          end
        end
      end

      def requests
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db
        @data = Beacnox::Reports::RequestsReport.new(db, group: :controller_action_format, sort: :count).data
        respond_to do |format|
          format.html
          format.csv do
            export_to_csv "requests_report", @data
          end
        end
      end

      def recent
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db
        @data = Beacnox::Reports::RecentRequestsReport.new(db).data(params[:from_timei])

        # example
        # :controller=>"HomeController",
        # :action=>"index",
        # :format=>"html",
        # :status=>"200",
        # :method=>"GET",
        # :path=>"/",
        # :request_id=>"9c9bff5f792a5b3f77cb07fa325f8ddf",
        # :datetime=>2023-06-24 21:22:46 +0300,
        # :datetimei=>1687630966,
        # :duration=>207.225830078125,
        # :db_runtime=>2.055999994277954,
        # :view_runtime=>67.8370000096038,
        # :exception=>nil,
        # :backtrace=>nil,
        # :http_referer=>nil,
        # "email"=>nil,
        # "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"}]

        respond_to do |format|
          format.html
          format.js
          format.csv do
            export_to_csv "recent_requests_report", @data
          end
        end
      end

      def slow
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db
        @data = Beacnox::Reports::SlowRequestsReport.new(db).data

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv "slow_requests_report", @data
          end
        end
      end

      def sidekiq
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :sidekiq)
        db = @datasource.db
        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Beacnox::Reports::ResponseTimeReport.new(db).data
        @recent_report_data = Beacnox::Reports::RecentRequestsReport.new(db).data
      end

      def delayed_job
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :delayed_job)
        db = @datasource.db
        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Beacnox::Reports::ResponseTimeReport.new(db).data
        @recent_report_data = Beacnox::Reports::RecentRequestsReport.new(db).data
      end

      def custom
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :custom)
        db = @datasource.db
        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Beacnox::Reports::ResponseTimeReport.new(db).data
        @recent_report_data = Beacnox::Reports::RecentRequestsReport.new(db).data
      end

      def grape
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :grape)
        db = @datasource.db
        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @recent_report_data = Beacnox::Reports::RecentRequestsReport.new(db).data
      end

      def rake
        @datasource = Beacnox::DataSource.new(**prepare_query(params), type: :rake)
        db = @datasource.db
        @throughput_report_data = Beacnox::Reports::ThroughputReport.new(db).data
        @recent_report_data = Beacnox::Reports::RecentRequestsReport.new(db).data
      end

      private

      def prepare_query(query = {})
        Beacnox::Rails::QueryBuilder.compose_from(query)
      end
    end
  end
end
