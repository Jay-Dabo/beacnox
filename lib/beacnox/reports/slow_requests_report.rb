module Beacnox
  module Reports
    class SlowRequestsReport < BaseReport
      def set_defaults
        @sort ||= :datetimei
      end

      def data
        db.data
          .collect { |e| e.record_hash }
          .select { |e| e if e[sort] > Beacnox.slow_requests_time_window.ago.to_i }
          .sort { |a, b| b[sort] <=> a[sort] }
          .filter { |e| e[:duration] > Beacnox.slow_requests_threshold.to_i }
          .first(limit)
      end

      private

      def limit
        Beacnox.slow_requests_limit ? Beacnox.slow_requests_limit.to_i : 100_000
      end
    end
  end
end
