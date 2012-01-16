class MessagesController < ApplicationController
  before_filter :require_admin_or_trustee
  helper_method :tax_options
  
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.new(params[:message])
    @message.user = current_user
    unless @message.tax.andand.managers.include? current_user
      redirect_to account_path, :notice => "You don't manage that tax, sorry."
      return
    end
    if @message.save
      redirect_to account_path, :notice => @message.published? ? "Successfully published and sent your message!" : "Saved your message as a draft."
    else
      render :action => 'new', :notice => "There was a problem and your mail wasn't saved."
    end
  end
  
  def edit
    @message = Message.find params[:id]
    redirect_to account_path, :notice => "You don't have permission for that." unless @message.tax.managers.include? current_user
  end  

  def update
    @message = Message.find params[:id]
    redirect_to account_path, :notice => "You don't have permission for that." unless @message.tax.managers.include? current_user
    @message.attributes = params[:message]
    unless @message.tax.andand.managers.include? current_user
      redirect_to account_path, :notice => "You don't have permission for that." and return
    end
    if @message.save
      redirect_to account_path, :notice => "Saved your changes to the message."
    else
      redirect_to account_path, :notice => "There was a problem saving those changes, oops."
    end
  end
  
  def destroy
  end
  
  protected
  
  def tax_options
    current_user.managed_taxes.collect { |t| [ t.name, t.id ] }
  end
  
end
