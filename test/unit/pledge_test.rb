require 'test_helper'

class PledgeTest < ActiveSupport::TestCase

  test "new pledge should validate" do
    pledge = FactoryGirl.build :pledge
    assert pledge.valid?
  end

  test "pledge collect function succeeds" do
    pledge = FactoryGirl.build :pledge
    pledge.collect

    assert_equal Pledge::ACTIVE, pledge.status
  end

end