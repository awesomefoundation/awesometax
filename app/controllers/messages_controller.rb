class MessagesController < ApplicationController
  helper_method :tax_options

  def new
    @message = Message.new(:tax_id => params[:tax_id])
  end

  def create
    @message = Message.new(params[:message])

    unless has_partial_tax_powers?(@message.tax_id)
      redirect_to account_path and return
    end

    @message.user = current_user

    if @message.save
      redirect_to account_path(:anchor => 'messages'), :notice => @message.published? ? "Successfully published and sent your message!" : "Saved your message as a draft."
    else
      render :action => 'new', :notice => "There was a problem and your mail wasn't saved."
    end
  end

  def edit
    @message = Message.find params[:id]

    unless has_partial_tax_powers?(@message.tax_id)
      redirect_to account_path and return
    end

    redirect_to account_path(:anchor => 'messages'), :notice => "You don't have permission for that." unless @message.tax.managers.include? current_user
  end

  def update
    @message = Message.find params[:id]
    unless has_partial_tax_powers?(@message.tax_id)
      redirect_to account_path and return
    end

    @message.attributes = params[:message]

    if @message.save
      redirect_to account_path(:anchor => 'messages'), :notice => "Saved your changes to the message."
    else
      redirect_to account_path(:anchor => 'messages'), :notice => "There was a problem saving those changes, oops."
    end
  end

  def destroy
  end

  protected

  def tax_options
    current_user.managed_taxes.collect { |t| [ t.name, t.id ] }
  end

end
