require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def teardown
    User.delete_all
  end
  
  test "signup works" do
    post :create, { :user => { :email => 'foofoo@enchantedforest.com', :password => 'hiphop', :name => 'Foo Foo' } }
    assert_not_nil UserSession.find
    assert_redirected_to account_url
  end
  
  test "incomplete signup fails" do
    post :create, { :user => { :email => '', :password => '', :name => 'Foo Bar' } }
    assert_template 'new'
    assert_nil UserSession.find

    post :create, { :user => { :email => 'foobar@enchantedforest.com', :password => '', :name => 'Foo Bar' } }
    assert_template 'new'
    assert_nil UserSession.find

    post :create, { :user => { :email => 'not_an_email', :password => 'whatsup', :name => 'Baz the Baz' } }
    assert_template 'new'
    assert_nil UserSession.find
  end
end
