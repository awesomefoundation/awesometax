class TaxesController < ApplicationController

  before_filter :require_admin_or_trustee, :except => [:index, :show]

  def index
    @taxes = Tax.active(:order => 'id asc').reverse
  end
  
  def show
    @tax = Tax.find_by_slug(params[:id]) || Tax.find(params[:id])
    @pledge = Pledge.new(:amount => 10, :tax_id => @tax.id)
    @pledges = @tax.pledges.active.order('amount desc')
    @pledgers = @tax.pledgers
    @my_pledges = user_signed_in? ? @tax.pledges.active.where(:user_id => current_user.id) : []
  end

  def new
    @tax = Tax.new(:goal => AppConfig.minimum_goal)
    fill_paypal_details(@tax)
  end
  
  def create
    unless verify_paypal(params[:tax][:paypal_email], params[:paypal_first], params[:paypal_last])
      redirect_to new_tax_path, :notice => "Sorry, we couldn't verify that PayPal account."
      return
    end 
 
    @tax = Tax.new(params[:tax])
    fill_paypal_details(@tax)
    if @tax.goal < AppConfig.minimum_goal
      flash[:notice] = "Your monthly minimum needs to be at least $#{AppConfig.minimum_goal}."
      render :action => 'new'
      return
    end
    
    @tax.status = Tax::ACTIVE
    @tax.owner = current_user # Deprecated, just holds the creator (ie person who entered paypal recipient info)
    
    if @tax.save
      @tax.managers << current_user
      redirect_to tax_path(@tax.slug)
    else
      flash[:notice] = "You need to fill out all the boxes. Don't forget to cross your i's and dot your t's!"
      render :action => 'new'
    end
  end
  
  def edit
    @tax = Tax.find_by_slug(params[:id]) || Tax.find(params[:id])
    redirect_to account_path and return unless admin? or (@tax.managers.include?(current_user.id) and @tax.active?)
  end
  
  def update
    @tax = Tax.find_by_slug(params[:id]) || Tax.find(params[:id])
    redirect_to :controller => 'taxes', :action => 'show', :id => @tax.slug
    return unless admin? or (@tax.managers.include?(current_user) and @tax.active?)
    @tax.update_attributes(params[:tax])
    #if video_details = get_media(params[:video_url])
    #  @tax.update_attributes({:video_type => video_details[:type].to_s, :video_id => video_details[:id]})
    #else
    #  @tax.update_attributes({:video_type => nil, :video_id => nil})
    #end 
  end
  
  def destroy
    @tax = Tax.find_by_slug(params[:id]) || Tax.find(params[:id])
    if @tax.managers.include?(current_user) or admin?
      @tax.stop
      redirect_to @tax, :notice => "You have discontinued this tax."
    else
      redirect_to @tax, :notice => "You don't own that tax so you can't end it."
    end
  end
  
  
  private

  def fill_paypal_details(tax)
    if Rails.env == 'production'
      tax.paypal_email = current_user.email
      @paypal_first = @paypal_last = nil
    else
      tax.paypal_email = 'sherad_1274768045_per@gmail.com'
      @paypal_first = 'Test'
      @paypal_last = 'User'
    end
  end
   
  # Return true if it's valid, false if we can't tell
  def verify_paypal(email, first, last)
   data = {
     "emailAddress"   => email,
     "matchCriteria"  => "NAME",
     "firstName"      => first,
     "lastName"       => last,
    }
    request = PaypalAdaptive::Request.new
    logger.info data.inspect
    response = request.get_verified_status(data)
    logger.info response.inspect
    return (response.success? and response['accountStatus'] == 'VERIFIED')
  end
  
  
end
