require "test_helper"
require "sidekiq/testing"

class SidekiqTest < ActiveSupport::TestCase
  test "works" do
    SimpleWorker.new.perform

    s = Beacnox::Gems::SidekiqExt.new
    res = s.call("worker", "msg", -> {}) do
      40 + 2
    end

    assert_equal 42, res
  end

  test "sidekiq worker with error" do
    Beacnox.redis.flushdb

    begin
      s = Beacnox::Gems::SidekiqExt.new
      s.call("worker", "msg", -> {}) do
        1 / 0
      end
    rescue
      "ignore me"
    end

    datasource = Beacnox::DataSource.new(q: {}, type: :sidekiq)
    db = datasource.db
    assert_equal db.data.last.status, "exception"
  end
end
