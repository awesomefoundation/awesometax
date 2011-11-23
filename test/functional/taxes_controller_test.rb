require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  def setup
  end
  
  def teardown
    Tax.delete_all
    User.delete_all
    UserSession.find.destroy unless UserSession.find.nil?
  end

  # Replace this with your real tests.
  test "anyone can start a tax" do
    t = Factory.build :tax
    u = t.owner
    UserSession.create u
    assert_difference('Tax.count') do
      post :create, { :tax => { :name => t.name, :description => t.description, :paypal_email => t.paypal_email } }
    end
    assert_redirected_to tax_path(Tax.last.id)
  end
  
  test "but they must be logged in" do
    return
    t = Factory.build :tax
    assert_difference('Tax.count', 0) do
      post :create, { :tax => { :name => t.name, :description => t.description, :paypal_email => t.paypal_email } }
    end
    assert_template 'new'
  end
end
