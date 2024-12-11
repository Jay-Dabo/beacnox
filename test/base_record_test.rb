require "test_helper"

class Beacnox::BaseRecord < ActiveSupport::TestCase
  test "ms" do
    record = Beacnox::Models::BaseRecord.new

    assert_equal record.send(:ms, 1), "1.0 ms"
  end
end
