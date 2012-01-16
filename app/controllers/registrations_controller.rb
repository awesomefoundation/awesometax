class RegistrationsController < Devise::RegistrationsController

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    attrs = params[resource_name]
    settings = attrs['settings']
    attrs.delete('settings')

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
    
    
=begin    
    @user = resource

    attrs = params[resource_name]
    settings = attrs['settings']
    attrs.delete('settings')
    
    if resource.update_attributes(attrs)
      resource.settings = settings
      flash[:notice] = "Saved your account settings."
      redirect_to account_path
    else
      flash[:notice] = "Couldn't save your account settings."
      redirect_to edit_user_registration_path
    end
=end
    
  end  

end