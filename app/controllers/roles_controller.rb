class RolesController < ApplicationController

  def index
    @tax = Tax.find_by_slug(params[:tax_id]) || Tax.find(params[:tax_id])

    unless admin? || (@tax.active? && @tax.managers.include?(current_user))
      redirect_to account_path and return
    end

    @supporters = @tax.pledgers - @tax.managers

  end

  def create
    @role = Role.new(params[:role])

    if @role.save
      redirect_to :back
    else
      flash[:notice] = @role.errors.full_messages.join(", ")
      redirect_to :back
    end

  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    redirect_to :back
  end

end