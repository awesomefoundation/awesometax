class TaxesController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]

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
    @tax = Tax.new(params[:tax])
    @tax.owner = current_user
    @tax.status = Tax::ACTIVE
    
    logger.info "video url: #{params[:video_url]}"
    if video_details = get_media(params[:video_url])
      logger.info video_details.inspect
      @tax.video_type = video_details[:type].to_s
      @tax.video_id = video_details[:id]
    end 
    
    if logged_in? and @tax.save
      redirect_to tax_path(@tax)
      begin; Mailer.deliver_admin_notification("#{@user.name} created a tax: #{@tax.name}", h(url_for(:controller => 'taxes', :action => 'show', @id => @tax.id))); rescue; end
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
  
  # From a vimeo/flickr/youtube URL, return { :type => :vimeo|:youtube, :id => ID] or nil if unrecognized
  def get_media(url)
    return nil if url.empty?
    
    result = url.scan(/.*vimeo\.com\/(\d+).*/i)
    return {:type => :vimeo, :id => result[0][0]} unless result.empty?
    
    # http://www.youtube.com/watch?v=9fciD_II7NI
    result = url.scan(/.*youtube\.com(?:\/)?(?:watch)?\?v=([0-9a-zA-Z_]+).*/i)
    return {:type => :youtube, :id => result[0][0]} unless result.empty?
    
    return nil
  end
  
end
