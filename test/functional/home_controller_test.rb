require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def teardown
    User.delete_all
  end
  
  test "homepage" do
    get :index
    assert_response :success
  end
  
  test "homepage logged in" do
    u = Factory.create :user
    UserSession.create u

    get :index
    assert_response :success
  end
end
