module Beacnox
  class Utils
    def self.time
      Time.now.utc
    end

    def self.from_datetimei(datetimei)
      Time.at(datetimei, in: "+00:00")
    end

    # date key in redis store
    def self.cache_key(now = Date.today)
      "date-#{now}"
    end

    # write to current slot
    # time - date -minute
    def self.field_key(now = Beacnox::Utils.time)
      now.strftime("%H:%M")
    end

    def self.fetch_from_redis(query)
      Beacnox.log "\n\n   [REDIS QUERY]   -->   #{query}\n\n"

      keys = Beacnox.redis.keys(query)
      return [] if keys.blank?
      values = Beacnox.redis.mget(keys)

      Beacnox.log "\n\n   [FOUND]   -->   #{values.size}\n\n"

      [keys, values]
    end

    def self.save_to_redis(key, value, expire = Beacnox.duration.to_i)
      # TODO think here if add return
      # return if value.empty?

      Beacnox.log "  [SAVE]    key  --->  #{key}\n"
      Beacnox.log "  [SAVE]    value  --->  #{value.to_json}\n\n"
      Beacnox.redis.set(key, value.to_json, ex: expire.to_i)
    end

    def self.days(duration = Beacnox.duration)
      (duration / 1.day) + 1
    end

    def self.median(array)
      sorted = array.sort
      size = sorted.size
      center = size / 2

      if size == 0
        nil
      elsif size.even?
        (sorted[center - 1] + sorted[center]) / 2.0
      else
        sorted[center]
      end
    end

    def self.percentile(values, percentile)
      return nil if values.empty?

      sorted = values.sort
      rank = (percentile.to_f / 100) * (sorted.size - 1)

      lower = sorted[rank.floor]
      upper = sorted[rank.ceil]
      lower + (upper - lower) * (rank - rank.floor)
    end
  end
end
