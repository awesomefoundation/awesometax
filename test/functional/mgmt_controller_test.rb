require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  test "regular users cannot view dashboard" do
    u = FactoryGirl.create :user
    sign_in u

    get :index
    assert_redirected_to root_path

  end

  test "trustees can view dashboard" do
    u = FactoryGirl.create :trustee
    sign_in u

    get :index
    assert_response :success

  end

end