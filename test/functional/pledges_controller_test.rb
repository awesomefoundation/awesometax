require 'test_helper'

class PledgesControllerTest < ActionController::TestCase

  def setup
  end

  def teardown
    User.delete_all
    Tax.delete_all
    Pledge.delete_all
  end

  test "should create pledge" do
    pledge = FactoryGirl.build :pledge
    pledge.user.save
    pledge.tax.save

    sign_in pledge.user

    assert_difference('Pledge.count') do
      post :create, { :pledge => { :amount => pledge.amount, :tax_id => pledge.tax.id } }
    end
  end

end
