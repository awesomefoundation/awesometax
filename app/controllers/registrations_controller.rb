class RegistrationsController < Devise::RegistrationsController

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    attrs = params[resource_name]
    settings = attrs['settings']
    attrs.delete('settings')
    attrs['picture'] = nil if params['remove_picture']
    #attrs['user']['url'] = "http://#{attrs['user']['url']}" if !attrs['user']['url'].blank? and !attrs['user']['url'].include?('http://')

    if resource.update_with_password(attrs)
      resource.update_settings(settings)
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end

  end

  def confirm_pledge
    unless session[:pledge_tax]
      redirect_to account_path and return
    end

    @tax = Tax.find(session[:pledge_tax])
    @pledge = Pledge.new(:amount => 10, :tax_id => @tax.id)
  end


  protected

  def after_sign_up_path_for(resource)
    if session[:pledge_tax]
      '/confirm_pledge'
    end
  end

end