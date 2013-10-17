class RegistrationsController < Devise::RegistrationsController

  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      if params[:pending_pledge_tax]
        flash[:pending_pledge_tax] = params[:pending_pledge_tax]
        flash[:pending_pledge_amount] = params[:pending_pledge_amount]
      end
      respond_with resource
    end
  end

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
      redirect_to edit_user_registration_path
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