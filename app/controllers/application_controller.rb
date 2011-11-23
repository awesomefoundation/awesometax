class ApplicationController < ActionController::Base
  layout 'application'
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :logged_in?, :admin?
  helper_method :require_user, :require_no_user, :store_location, :redirect_back_or_default
  helper_method :notice, :num_taxpayers, :total_monthly, :next_collection_time, :time_until_collection

  private
  
    
    def logged_in?
      !!current_user
    end
    
    def admin?
      logged_in? and current_user.admin?
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def require_admin
      unless admin?
        flash[:notice] = "Management only beyond this point, sorry."
        redirect_to root_url
        return false 
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def notice
      flash[:notice].nil? ? '' : "<p class='notice'>#{flash[:notice]}</p>"
    end
    
    
    def num_taxpayers
      Pledge.count(:select => 'distinct user_id', :conditions => { :status => Pledge::ACTIVE })
    end
    def total_monthly
      Pledge.sum(:amount, :conditions => { :status => Pledge::ACTIVE })
    end
    def next_collection_time
      # 9am pacific on the 15th
      time = Date.today.at_beginning_of_month + 14.days + 9.hours
      time = Date.today.at_end_of_month + 15.days + 9.hours if time < Time.zone.now
      time
    end
    def time_until_collection
      next_collection_time - Time.zone.now
    end
    
end
