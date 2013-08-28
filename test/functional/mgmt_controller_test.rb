require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  test "regular users cannot view dashboard" do
    u = FactoryGirl.create :user
    sign_in u

    get :index
    assert_redirected_to root_path

  end


end