class UsersController < ApplicationController

  def show
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    redirect_to root_url and return if @user.nil?
    @myself = current_user.andand.id == @user.id

    @managed = @user.managed_taxes.order('status, created_at desc')
    @trusted = @user.trusted_taxes.order('status, created_at desc')
    @supervised = @user.managed_taxes + @user.trusted_taxes

    #@funded = @user.funded_taxes.order('status, created_at desc')

    if @myself
      @pledges        = @user.pledges.order('status, created_at desc')
      @active_sum     = @user.pledges.active.sum(:amount)
      @active_count   = @user.pledges.active.count

      supervised_pledges = @supervised.collect { |t| t.pledges.active }.flatten
      @supervised_count  = supervised_pledges.count
      @supervised_sum    = supervised_pledges.inject(0) { |sum,i| sum + i.amount }

      @total_given    = @user.transactions.sum(:amount)
      @transactions   = @user.transactions.sort { |a,b| b.id <=> a.id }

      @messages       = @user.messages.published
      @sent           = @user.sent_messages
    else
      @pledges = @user.pledges.order('created_at desc')
    end
  end

end
