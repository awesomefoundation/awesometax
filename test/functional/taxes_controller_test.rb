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

  test "managers can edit tax" do
    u = FactoryGirl.create :manager
    t = u.managed_taxes.first
    sign_in u

    get :edit, :id => t.id
    assert_response :success

  end

  test "trustees can edit tax" do
    u = FactoryGirl.create :trustee
    t = u.trusted_taxes.first
    sign_in u

    get :edit, :id => t.id
    assert_response :success

  end


end
