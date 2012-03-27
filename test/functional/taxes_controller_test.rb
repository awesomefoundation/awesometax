require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  @@tax_params= {
    :name => "Awesome PDX",
    :description => "Quick brown foxes jumping over lazy dogs.",
    :goal => 1500,
    :paypal_first => 'Test',
    :paypal_last => 'User',
    :paypal_email => 'sherad_1274768045_per@gmail.com' 
  }
  
  def setup
  end
  
  def teardown
    Tax.delete_all
    User.delete_all
  end

  test "regular users can not start taxes" do
    u = Factory.create :user
    sign_in u

    assert_difference('Tax.count', 0) do
      post :create, { :tax => @@tax_params }
    end
    assert_redirected_to root_path
  end
  
  test "trustees can make taxes" do
    u = Factory.create :trustee
    sign_in u

    assert_difference('Tax.count') do
      post :create, { :tax => @@tax_params }
    end
    assert_
    assert_redirected_to tax_path(Tax.last.id)
  end
end
