module Beacnox
  class CurrentRequest
    attr_reader :request_id, :tracings, :ignore
    attr_accessor :data
    attr_accessor :record

    def self.init
      Thread.current[:rp_current_request] ||= CurrentRequest.new(SecureRandom.hex(16))
    end

    def self.current
      CurrentRequest.init
    end

    def self.cleanup
      Beacnox.log "----------------------------------------------------> CurrentRequest.cleanup !!!!!!!!!!!! -------------------------\n\n"
      Beacnox.skip = false
      Thread.current[:rp_current_request] = nil
    end

    def initialize(request_id)
      @request_id = request_id
      @tracings = []
      @ignore = Set.new
      @data = nil
      @record = nil
    end

    def trace(options = {})
      @tracings << options.merge(time: Beacnox::Utils.time.to_i)
    end
  end
end
