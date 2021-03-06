class AdminController < ApplicationController
  before_filter :require_admin

  def index
    @users = User.all(:limit => 25, :order => 'id desc')
    @taxes = Tax.all
    @transfers = Transfer.all
    @transactions = Transaction.all(:order => 'id desc')
    @comments = Comment.all(:order => 'id desc')
  end

end
