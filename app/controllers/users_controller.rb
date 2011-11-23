class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update, :history]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for joining!"
      UserSession.create @user
      begin; Mailer.deliver_welcome(@user); rescue; end
      redirect_back_or_default account_url
      begin; Mailer.deliver_admin_notification("New user #{@user.name}", "Just to let you know someone joined!"); rescue; end
    else
      flash[:notice] = "There was a problem creating your account."
      render :action => :new
    end
  end
  
  def show
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    redirect_to root_url and return if @user.nil?
    myself = current_user.andand.id == @user.id
    @taxes = @user.taxes.sort { |a,b| a.status <=> b.status }
    @pledges = Pledge.all(:conditions => myself ? ['user_id = ? and status > ?', @user.id, Pledge::INACTIVE] :
      ['user_id = ? and status = ?', @user.id, Pledge::ACTIVE], :order => 'status, created_at desc')
    @total_pledges = Pledge.sum(:amount, :conditions => { :user_id => @user.id, :status => Pledge::ACTIVE })
    @active_pledges_count = Pledge.count(:conditions => ['user_id = ? and status = ?', @user.id, Pledge::ACTIVE])
  end
  
  # Transaction history
  def history
    @user = current_user
    @transactions = current_user.transactions.sort { |a,b| b.id <=> a.id }
    @active_sum = Pledge.sum(:amount, :conditions => { :user_id => current_user.id, :status => Pledge::ACTIVE })
    @active_count = Pledge.count(:conditions => { :user_id => current_user.id, :status => Pledge::ACTIVE })
  end

  def edit
    @user = @current_user
    @email_pref_comments = @user.wants_email? Mailer::TAX_COMMENTS
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    logger.info "Hi, #{params[:email_pref_comments].to_i}"
    wants_comments = params[:email_pref_comments].to_i == 1
    params[:user][:email_prefs] = @user.set_email_pref(Mailer::TAX_COMMENTS, wants_comments)
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
end
