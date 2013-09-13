class TransactionsController < ApplicationController

  def index
    unless has_full_tax_powers?(params[:tax_id])
      redirect_to account_path and return
    end

    @tax = Tax.find_tax(params[:tax_id])
  end

end