require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  test "trustees cannot view roles mgmt" do
    u = FactoryGirl.create :trustee
    t = u.trusted_taxes.first
    sign_in u

    get :index, :tax_id => t.id
    assert_redirected_to account_path

  end

  test "managers can view roles mgmt" do
    u = FactoryGirl.create :manager
    t = u.managed_taxes.first
    sign_in u

    get :index, :tax_id => t.id
    assert_response :success

  end

end