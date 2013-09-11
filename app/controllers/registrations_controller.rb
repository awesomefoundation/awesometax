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


  protected


  def after_sign_up_path_for(resource)
    if params[:pending_pledge_tax]
      "/confirm_pledge?tax_id=#{params[:pending_pledge_tax]}&amount=#{params[:pending_pledge_amount]}"
    end
  end

end