class PledgesController < ApplicationController

  before_filter :authenticate_user!, :only => [:create, :update, :destroy, :start, :pause, :stop, :collect]
  protect_from_forgery :except => :notify # IPN gets invalid auth token messages otherwise

  def show
    @pledge = Pledge.find params[:id]
  end
  
  def create
    @pledge = Pledge.new(params[:pledge])
    @pledge.attributes = {
      :user => current_user,
      :starts => Time.zone.now,
      :ends => Time.zone.now + 1.year,
      :status => Pledge::INACTIVE
    }
    unless @pledge.tax.andand.active? and @pledge.save
      redirect_to @pledge.tax, :notice => "That wasn't allowed, sorry."
      return
    end
    
    pay_request = PaypalAdaptive::Request.new
    receiverList = [ { 'email' => @pledge.tax.paypal_email, 'amount' => @pledge.recipient_cut.to_s } ]
    receiverList << { 'email' => AppConfig.paypal_email, 'amount' => @pledge.loveland_cut.to_s } if AppConfig.loveland_fee > 0

    data = {
      'actionType'          => 'PAY',
      'requestEnvelope'     => { 'errorLanguage' => 'en_US' },
      'currencyCode'        => 'USD',
      'returnUrl'           => url_for(:controller => 'pledges', :action => 'completed', :id => @pledge.id, :only_path => false),
      'cancelUrl'           => url_for(:controller => 'pledges', :action => 'canceled',  :id => @pledge.id, :only_path => false),
      'receiverList'        => { 'receiver' => receiverList },
      'fees_payer'          => 'EACHRECEIVER',
      'ipnNotificationUrl'  => url_for(:controller => 'pledges', :action => 'notify'),
      'maxTotalAmountOfAllPayments' => (12 * @pledge.amount).to_s,
      'maxAmountPerPayment'         => @pledge.amount.to_s,
      'maxNumberOfPayments'         => '12',
      'startingDate'                => @pledge.starts.strftime('%Y-%m-%dT%H:%M:%S-00:00'),
      'endingDate'                  => @pledge.ends.strftime('%Y-%m-%dT%H:%M:%S-00:00')
    }
    pay_response = @response = pay_request.preapproval(data)
    
    if pay_response.success?
      @pledge.update_attribute(:preapproval_key, pay_response['preapprovalKey'])
      redirect_to pay_response.preapproval_paypal_payment_url
    else
      flash[:notice] = pay_response.errors.first['message'] + '... request=' + data.to_json + '... response=' + @response.inspect
      redirect_to @pledge.tax
    end
  end
  
  
  def completed
    pledge = Pledge.find params[:id]
    pledge.user ||= current_user
    preapproval_key = pledge.preapproval_key
    pay_request = PaypalAdaptive::Request.new
    data = {
      'preapprovalKey' => preapproval_key,
      'requestEnvelope' => { 'errorLanguage' => 'en_US' },
      'currencyCode' => 'USD'
      }
    response = pay_request.preapproval_details(data)
    logger.info response.inspect
    unless response['approved'] == 'true'
      flash[:notice] = "We couldn't verify your preapproval..."
      redirect_to pledge.tax
      return
    end
    if pledge.amount != response['maxAmountPerPayment'].to_f
      flash[:notice] = "There was a mismatch between our pledge amount and PayPal's."
      redirect_to pledge.tax
      return
    end
    
    pledge.update_attribute(:status, Pledge::ACTIVE)
    pledge.tax.funders << current_user
    
    begin
      Mailer.new_pledge(pledge.tax.owner, pledge).deliver
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
    end
    
    flash[:notice] = 'Thank you for pledging!'
    #redirect_to :action => 'thanks', :id => pledge.id
    redirect_to pledge.tax
  end
  
  def thanks
    @pledge = Pledge.find params[:id]
  end
  
  def canceled
    pledge = Pledge.find params[:id]
    if pledge.user == current_user
      pledge.delete
    end
    flash[:notice] = 'Canceled your payment.'
    redirect_to pledge.tax
  end
  
  # IPN, we don't have to do anything
  def notify
    render :text => 'Ok, thank you.'
  end
  
  
  def start
    @pledge = Pledge.find params[:id]
    redirect_to account_path
    return unless @pledge.user_id == current_user.id and @pledge.status == Pledge::PAUSED
    @pledge.start
  end
  def pause
    @pledge = Pledge.find params[:id]
    redirect_to account_path
    return unless @pledge.user_id == current_user.id and @pledge.status == Pledge::ACTIVE
    @pledge.pause
  end
  def stop
    @pledge = Pledge.find params[:id]
    redirect_to account_path
    return unless @pledge.user_id == current_user.id and [Pledge::ACTIVE, Pledge::PAUSED].include? @pledge.status
    @pledge.stop
  end
  
  
  # Force collection right now of your own pending pledges. This is for testing!
  def collect
    redirect_to history_path
    if Rails.env == 'production'
      flash[:notice] = "This feature's for testing only."
      return
    end
    
    current_user.pledges.active.each do |p|
      p.collect
    end
  end
  
end
