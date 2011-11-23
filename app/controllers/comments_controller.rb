class CommentsController < ApplicationController
  before_filter :require_user, :only => [ :create, :destroy ]
  include ActionView::Helpers::TextHelper

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
    begin
      Mailer.deliver_comment(@tax.owner, @comment) if @tax.owner.wants_email?(Mailer::TAX_COMMENTS)
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
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

