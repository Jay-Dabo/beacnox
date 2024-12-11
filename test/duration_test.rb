require "test_helper"

class Beacnox::Test1 < ActiveSupport::TestCase
  test "duration report" do
    Beacnox.duration = 24.hours

    @datasource = Beacnox::DataSource.new(type: :requests)
    @data = Beacnox::Reports::ThroughputReport.new(@datasource.db).data

    assert_equal @data.size / 60, 24
  end
end
