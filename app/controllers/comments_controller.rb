class CommentsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :authenticate_user!, :only => [ :create, :destroy ]

  def create
    @tax = Tax.find(params[:tax])
    message = params[:body]
    
    @comment = Comment.new({ :body => message, :tax => @tax, :user => current_user })
    
    redirect_to :controller => 'taxes', :action => 'show', :id => @tax.id
    unless @comment.save
      flash[:notice] = "Error saving the comment! What!"
      logger.info @comment.errors.inspect
      return
    end
  end

	def destroy 
    @comment = Comment.find(params[:id])
    tax = @comment.tax
    redirect_to :controller => 'taxes', :action => 'show', :id => tax.id
		unless @comment.editable_by(current_user)
      flash[:notice] = "You don't have permission to delete that. Nice try."
      return
    end
    @comment.delete
    flash[:notice] = "You removed the comment."
  end
  
end

