class UsersController < ApplicationController
    
  def show
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    redirect_to root_url and return if @user.nil?
    @myself = current_user.andand.id == @user.id
    
    @managed = @user.managed_taxes.order('status, created_at desc')
    #@funded = @user.funded_taxes.order('status, created_at desc')
    
    if @myself
      @pledges        = @user.pledges.order('status, created_at desc').where('status > 0')
      @active_sum     = @user.pledges.active.sum(:amount)
      @active_count   = @user.pledges.active.count
      
      managed_pledges = @managed.collect { |t| t.pledges.active }.flatten
      @managed_count  = managed_pledges.count
      @managed_sum    = managed_pledges.inject(0) { |sum,i| sum + i.amount }
      
      @total_given    = @user.transactions.sent.sum(:amount)
      @total_received = @user.transactions.received.sum(:amount)
      @transactions   = @user.transactions.sort { |a,b| b.id <=> a.id }
      
      @messages       = @user.messages.published
      @sent           = @user.sent_messages
    else
      @pledges = @user.pledges.active.order('created_at desc')
    end
  end
    
end
