module Beacnox
  module Reports
    class PercentileReport < BaseReport
      def data
        durations = db.data.collect(&:duration).compact
        {
          p50: Beacnox::Utils.percentile(durations, 50),
          p95: Beacnox::Utils.percentile(durations, 95),
          p99: Beacnox::Utils.percentile(durations, 99)
        }
      end
    end
  end
end
