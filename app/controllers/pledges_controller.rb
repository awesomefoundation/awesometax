class PledgesController < ApplicationController

  before_filter :redirect_if_logged_out_and_store_pending_pledge, :only => :create
  before_filter :authenticate_user!, :only => [:update, :destroy, :start, :pause, :stop, :collect, :confirm_pledge]
  protect_from_forgery :except => :notify # IPN gets invalid auth token messages otherwise

  def show
    @pledge = Pledge.find params[:id]
  end

  def create
    begin
      customer = Stripe::Customer.create(
        :card => params[:stripeToken],
        :description => "payinguser@example.com"
      )
    rescue => e
      errors[:base] << "#{e.message}"
      return
    end

    #create pledge
    @pledge = Pledge.new(params[:pledge])
    @pledge.attributes = {
      :user => current_user,
      :starts => Time.zone.now,
      :ends => Time.zone.now + 1.year,
      :status => Pledge::ACTIVE,
      :stripe_token => customer.id
    }

    if @pledge.save
      respond_to do |format|
        format.html { redirect_to @pledge.tax, :notice => "Thanks, you created a monthly pledge of $#{params[:pledge][:amount]}" }
        format.json { render html: "<h2>Thanks, you created a monthly pledge of <strong>$#{params[:pledge][:amount]}</strong>!</h2>"}
      end
    else
      respond_to do |format|
        format.html { redirect_to @pledge.tax, :notice => @pledge.errors.full_messages.join(", ") }
        format.json { render json: @pledge.errors.full_messages.join(", "), :status => :unprocessable_entity}
      end
    end
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
    current_user.funded_taxes << @pledge.tax
    @pledge.start
  end
  def pause
    @pledge = Pledge.find params[:id]
    redirect_to account_path
    return unless @pledge.user_id == current_user.id and @pledge.status == Pledge::ACTIVE
    current_user.funded_taxes.delete(@pledge.tax)
    @pledge.pause
  end
  def stop
    @pledge = Pledge.find params[:id]
    redirect_to account_path
    return unless @pledge.user_id == current_user.id and [Pledge::ACTIVE, Pledge::PAUSED].include? @pledge.status
    current_user.funded_taxes.delete(@pledge.tax)
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

  def confirm_pledge
    unless params[:tax_id] && params[:amount]
      redirect_to account_path and return
    end

    @tax = Tax.find(params[:tax_id])
    @pledge = Pledge.new(:amount => params[:amount], :tax_id => params[:tax_id])
  end

  private

  def redirect_if_logged_out_and_store_pending_pledge
    unless user_signed_in?
      flash[:pending_pledge_tax] = params[:pledge][:tax_id]
      flash[:pending_pledge_amount] = params[:pledge][:amount]
      redirect_to new_user_registration_path
    end
  end

end
