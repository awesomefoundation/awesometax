require 'test_helper'

class PledgesControllerTest < ActionController::TestCase

  @@fake_url = 'http://sandbox.paypal.com/foo'

  def setup
    PaypalAdaptive::Request.any_instance.stubs(:preapproval).returns(
      PaypalAdaptive::Response.new({
      'preapprovalKey' => 'toucan',
      'responseEnvelope' => {'ack' => 'Success'}
      }))
    PaypalAdaptive::Request.any_instance.stubs(:preapproval_details).returns(
      PaypalAdaptive::Response.new({
        'approved' => 'true',
        'maxAmountPerPayment' => '5',
        'responseEnvelope' => {'ack' => 'Success'}
      }))
    PaypalAdaptive::Response.any_instance.stubs(:preapproval_paypal_payment_url).returns(@@fake_url)    
  end
  
  def teardown
    User.delete_all
    Tax.delete_all
    Pledge.delete_all
  end

  test "should create pledge" do
    pledge = Factory.build :pledge
    pledge.user.save
    pledge.tax.save
    
    UserSession.create pledge.user
    
    assert_difference('Pledge.count') do
      post :create, { :pledge => { :amount => pledge.amount, :tax_id => pledge.tax.id } }
    end
    assert_response :redirect
    assert_redirected_to @@fake_url
  end
  
  test "should complete the pledge" do
    # Coming back from paypal it's a get with just the id
    p = Factory.create :started
    assert_equal Pledge::INACTIVE, Pledge.last.status
    get :completed, { :id =>  p.id }
    assert_equal Pledge::ACTIVE, Pledge.last.status
    assert_redirected_to "/pledges/thanks/#{p.id}"
  end
    
end
