require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  test "managers can create messages" do
    u = FactoryGirl.create :manager
    t = u.managed_taxes.first
    sign_in u

    assert_difference('Message.count') do
      post :create, { :message => {tax_id: t.id, title: 'test', body: 'hi guys', status: 0} }
    end
  end

  test "trustees can create messages" do
    u = FactoryGirl.create :trustee
    t = u.trusted_taxes.first
    sign_in u

    assert_difference('Message.count') do
      post :create, { :message => {tax_id: t.id, title: 'test', body: 'hi guys', status: 0} }
    end
  end

end
