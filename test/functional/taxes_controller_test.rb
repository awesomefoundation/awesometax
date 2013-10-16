require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  @@tax_params= {
    :name => "Awesome PDX",
    :description => "Quick brown foxes jumping over lazy dogs.",
    :goal => 1500,
    :bank_token => 'btok_2lVK2WWdvctLOj'
  }

  def setup
    # account = Stripe::BankAccount.create(
    #   :country => "US",
    #   :routing_number => "110000000",
    #   :account_number => "000123456789"
    # )
    # @@tax_params['bank_token'] = account.id
  end

  def teardown
    Tax.delete_all
    User.delete_all
  end

  test "regular users can not start taxes" do
    u = FactoryGirl.create :user
    sign_in u

    assert_difference('Tax.count', 0) do
      post :create, { :tax => @@tax_params }
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
