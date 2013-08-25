require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def teardown
    #User.delete_all
  end

  test "homepage" do
    get :index
    assert_response :success
  end

  test "homepage logged in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    u = FactoryGirl.create :user
    sign_in u

    get :index
    assert_response :success
  end
end
