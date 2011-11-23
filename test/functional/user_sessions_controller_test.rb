require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def teardown
    User.delete_all
  end
  
  def test_new
    get :new
    assert_response :success
  end
  
  def test_create_invalid
    #UserSession.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_response :success
    # and.. template is 'new'
  end
  
  def test_create_valid
    u = Factory.create :user
    post :create, { :email => u.email, :password => 'lettuce' }
    assert_redirected_to account_url
    assert_not_nil UserSession.find
  end
  
  def test_logout
    u = Factory.create :user
    UserSession.create u
    assert_not_nil UserSession.find
    
    delete :destroy
    assert_redirected_to root_url
    assert_nil UserSession.find
  end
end
