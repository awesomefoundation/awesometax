class HomeController < ApplicationController
  
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  
  def index
    @featured_left  = Tax.find 1
    @featured_right = Tax.find 2
  end
  
  def mock
  end
  
  def widget
    @tax = Tax.find(params[:id])
    @json = {
      :id           => @tax.id,
      :name         => @tax.name,
      :description  => markdown(truncate(@tax.description.gsub(/<\/?[^>]*>/, ""), :length => 240)),
      :supporters   => @tax.unique_supporters.count,
      :monthly      => number_to_currency(@tax.monthly_income),
      :created      => @tax.created_at.strftime('%m-%d-%y')
    }.to_json
  end
  
end
