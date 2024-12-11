module Beacnox
  module Gems
    class SidekiqExt
      def initialize(options = nil)
      end

      def call(worker, msg, queue)
        now = Beacnox::Utils.time
        record = Beacnox::Models::SidekiqRecord.new(
          enqueued_ati: msg["enqueued_at"].to_i,
          datetimei: msg["created_at"].to_i,
          jid: msg["jid"],
          queue: queue,
          start_timei: now.to_i,
          datetime: now.strftime(Beacnox::FORMAT),
          worker: msg["wrapped".freeze] || worker.class.to_s
        )
        begin
          result = yield
          record.status = "success"
          result
        rescue Exception => ex # rubocop:disable Lint/RescueException
          record.status = "exception"
          record.message = ex.message
          raise ex
        ensure
          # store in ms instead of seconds
          record.duration = (Beacnox::Utils.time - now) * 1000
          record.save
        end
      end
    end
  end
end
