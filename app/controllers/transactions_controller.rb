class TransactionsController < ApplicationController

  def index
    unless has_full_tax_powers?(params[:tax_id])
      redirect_to account_path and return
    end

    @tax = Tax.find_by_slug(params[:tax_id]) || Tax.find(params[:tax_id])
  end

end