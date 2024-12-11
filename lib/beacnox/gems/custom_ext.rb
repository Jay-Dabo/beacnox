module Beacnox
  module Gems
    module CustomExtension
      extend self

      def measure(tag_name, namespace_name = nil)
        return yield unless Beacnox.enabled
        return yield unless Beacnox.include_custom_events

        begin
          now = Beacnox::Utils.time
          status = "success"
          result = yield
          result
        rescue Exception => ex # rubocop:disable Lint/RescueException
          status = "error"
          raise(ex)
        ensure
          Beacnox::Models::CustomRecord.new(
            tag_name: tag_name,
            namespace_name: namespace_name,
            status: status,
            duration: (Beacnox::Utils.time - now) * 1000,
            datetime: now.strftime(Beacnox::FORMAT),
            datetimei: now.to_i
          ).save
        end
      end
    end
  end
end
