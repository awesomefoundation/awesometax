class TaxesController < ApplicationController

  before_filter :require_admin, :only => [:new, :create]

  def index
    @taxes = Tax.active(:order => 'id asc').reverse
  end

  def show
    @tax = Tax.find_tax(params[:id])
    @pledge = Pledge.new(:amount => 10, :tax_id => @tax.id)
    @pledges = @tax.pledges.active.order('amount desc')
    @pledgers = @tax.pledgers
    @my_pledges = user_signed_in? ? @tax.pledges.active.where(:user_id => current_user.id) : []
  end

  def history
    @tax = Tax.find_tax(params[:tax_id])
    @transactions = @tax.transactions.received
    @sorted = @transactions.group_by {|t| t.created_at.beginning_of_day}
  end

  def new
    @tax = Tax.new(:goal => AppConfig.minimum_goal)
  end

  def create
    @tax = Tax.new(params[:tax])
    if @tax.goal < AppConfig.minimum_goal
      flash[:notice] = "Your monthly minimum needs to be at least $#{AppConfig.minimum_goal}."
      render :action => 'new'
      return
    end

    @tax.status = Tax::ACTIVE
    @tax.owner = current_user # Deprecated, just holds the creator (ie person who entered paypal recipient info)

    if @tax.save
      @tax.managers << current_user
      respond_to do |format|
        format.html { redirect_to redirect_to tax_path(@tax.slug) }
        format.json { render json: {url: tax_path(@tax.slug)}}
      end
    else
      respond_to do |format|
        format.html { redirect_to new_tax_path, :notice => @tax.errors.full_messages.join(", ") }
        format.json { render json: @tax.errors.full_messages.join(", "), :status => :unprocessable_entity}
      end
    end
  end

  def edit
    unless has_partial_tax_powers?(params[:id])
      redirect_to account_path and return
    end

    @tax = Tax.find_tax(params[:id])
  end

  def update
    unless has_partial_tax_powers?(params[:id])
      redirect_to account_path and return
    end

    @tax = Tax.find_tax(params[:id])
    redirect_to :controller => 'taxes', :action => 'show', :id => @tax.slug
    logger.info "one"
    return unless admin? or (@tax.managers.include?(current_user) and @tax.active?)
    logger.info "two"
    @tax.update_attributes(params[:tax])
    logger.info "three.. #{params[:tax].inspect}"
    #if video_details = get_media(params[:video_url])
    #  @tax.update_attributes({:video_type => video_details[:type].to_s, :video_id => video_details[:id]})
    #else
    #  @tax.update_attributes({:video_type => nil, :video_id => nil})
    #end
  end

  def destroy
    unless has_full_tax_powers?(params[:id])
      redirect_to account_path and return
    end

    @tax = Tax.find_tax(params[:tax_id])
    if @tax.managers.include?(current_user) or admin?
      @tax.stop
      redirect_to @tax, :notice => "You have discontinued this tax."
    else
      redirect_to @tax, :notice => "You don't own that tax so you can't end it."
    end
  end


end
