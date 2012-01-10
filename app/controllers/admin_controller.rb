class AdminController < ApplicationController
  before_filter :require_admin_or_trustee
  
  def index
    @users = User.all(:limit => 25, :order => 'id desc')
    @taxes = Tax.all
    @transactions = Transaction.all(:order => 'id desc')
    @comments = Comment.all(:order => 'id desc')
  end
  
  def invite
    redirect_to admin_path, :notice => "You need to enter an email and name." and return if params[:email].blank? or params[:name].blank?
    User.invite!({:email => params[:email], :name => params[:name]}, current_user)
    invited = User.last.update_attribute(:status, User::TRUSTEE)
    redirect_to admin_path, :notice => "Sent invitation to #{params[:email]}."
  end
  
end
