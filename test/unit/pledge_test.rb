require 'test_helper'

class PledgeTest < ActiveSupport::TestCase

  test "new pledge should validate" do
    pledge = FactoryGirl.build :pledge
    assert pledge.valid?
  end

  test "pledge collect function succeeds" do
    transactions_count = Transaction.all.count
    pledge = FactoryGirl.build :pledge
    pledge.collect

    assert_equal Pledge::ACTIVE, pledge.status
    # assert_equal transactions_count+1, Transaction.all.count
  end

  test "pledge that can't collect becomes inactive" do
    pledge = FactoryGirl.build :pledge
    pledge.stripe_token = "xxxxxxx"
    pledge.save
    pledge.collect

    assert_equal Pledge::INACTIVE, pledge.status
  end

end
