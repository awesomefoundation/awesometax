require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  @@tax_params= {
    :name => "Awesome PDX",
    :description => "Quick brown foxes jumping over lazy dogs.",
    :goal => 1500,
    :paypal_email => 'sherad_1274768045_per@gmail.com',
  }

  def setup
  end

  def teardown
    Tax.delete_all
    User.delete_all
  end

  test "regular users can not start taxes" do
    u = FactoryGirl.create :user
    sign_in u

    assert_difference('Tax.count', 0) do
      post :create, { :tax => @@tax_params, :paypal_first => 'Test', :paypal_last => 'User' }
    end
    assert_redirected_to root_path
  end

  test "trustees can make taxes" do
    u = FactoryGirl.create :trustee
    sign_in u

    assert_difference('Tax.count') do
      post :create, { :tax => @@tax_params, :paypal_first => 'Test', :paypal_last => 'User' }
    end
    assert_redirected_to tax_path(Tax.last.slug)
  end
end
