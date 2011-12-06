class TaxesController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]

  def index
    @taxes = Tax.active(:order => 'id desc').reverse
  end
  
  def show
    @tax = Tax.find params[:id]
    @pledge = Pledge.new(:amount => 10, :tax_id => @tax.id)
  end
  
  def new
    @tax = Tax.new
    @tax.paypal_email = current_user.email
  end
  
  def create
    unless verify_paypal(params[:tax][:paypal_email], params[:paypal_first], params[:paypal_last])
      redirect_to new_tax_path, :notice => "Sorry, we couldn't verify that PayPal account."
      return
    end 
    
    @tax = Tax.new(params[:tax])
    @tax.owner = current_user
    @tax.status = Tax::ACTIVE
    
    if @tax.save
      redirect_to tax_path(@tax)
      begin
        Mailer.deliver_admin_notification("#{@user.name} created a tax: #{@tax.name}", h(url_for(:controller => 'taxes', :action => 'show', @id => @tax.id)))
      rescue => e
      end
    else
      flash[:now] = "You need to fill out all the boxes. Don't forget to cross your i's and dot your t's!"
      render :action => 'new'
    end
  end
  
  def edit
    @tax = Tax.find params[:id]
    redirect_to account_path and return unless @tax.owner_id == current_user.id and @tax.active?
  end
  
  def update
    @tax = Tax.find params[:id]
    redirect_to :controller => 'taxes', :action => 'show', :id => @tax.id
    return unless @tax.owner_id == current_user.id and @tax.active?
    @tax.update_attributes(params[:tax])
    if video_details = get_media(params[:video_url])
      @tax.update_attributes({:video_type => video_details[:type].to_s, :video_id => video_details[:id]})
    else
      @tax.update_attributes({:video_type => nil, :video_id => nil})
    end 
  end
  
  def destroy
    @tax = Tax.find params[:id]
    unless @tax.owner == current_user or admin?
      redirect_to :action => 'show', :id => @tax.id
      flash[:notice] = "You don't own that tax so you can't end it."
      return
    end
    @tax.stop
    redirect_to @tax
    flash[:notice] = "You have discontinued this tax."
  end
  
  
  private

 
  # Return true if it's valid, false if we can't tell
  def verify_paypal(email, first, last)
   data = {
     "emailAddress"   => email,
     "matchCriteria"  => "NAME",
     "firstName"      => first,
     "lastName"       => last,
    }
    request = PaypalAdaptive::Request.new
    response = pay_request.get_verified_status(data)
    return r.success? and r['accountStatus'] == 'VERIFIED'
  end
  
  
end
