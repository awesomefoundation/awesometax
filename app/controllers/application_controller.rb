class ApplicationController < ActionController::Base
  layout 'application'
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_user_session, :current_user, :admin?, :trustee?
  helper_method :store_location, :redirect_back_or_default
  helper_method :markdown, :num_taxpayers, :total_monthly, :next_collection_time, :time_until_collection

  private

    def admin?
      current_user.andand.admin?
    end
    def trustee?
      current_user.andand.trustee?
    end

    def require_admin
      unless admin?
        redirect_to root_url, :notice => "Administrators only beyond this point, sorry."
        return false
      end
    end
    def require_trustee
      unless trustee?
        redirect_to root_url, :notice => "Board members only beyond this point, sorry."
        return false
      end
    end
    def require_admin_or_trustee
      unless admin? or trustee?
        redirect_to root_url, :notice => "Trustees and admins only beyond this point, sorry."
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

    def markdown(str)
      BlueCloth::new(str).to_html
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
