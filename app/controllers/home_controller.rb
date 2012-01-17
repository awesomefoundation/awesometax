class HomeController < ApplicationController
  
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  
  def index
    @taxes = Tax.active.order('id asc')
    @left = @taxes[0, (@taxes.size/2.0).ceil]
    @right = @taxes[(@taxes.size/2.0).ceil...@taxes.size]
  end
  
  def mock
    render :layout => false if params[:unstyled] == '1'
  end
  
  def widget
    @tax = Tax.find(params[:id])
    @json = {
      :id           => @tax.id,
      :name         => @tax.name,
      :description  => markdown(truncate(@tax.description.gsub(/<\/?[^>]*>/, ""), :length => 240)),
      :supporters   => pluralize(@tax.unique_supporters.count, 'person'),
      :monthly      => number_to_currency(@tax.monthly_income, :precision => 0),
      :created      => @tax.created_at.strftime('%m-%d-%y'),
      :goal         => @tax.goal,
      :percent      => @tax.percent_funded,
    }.to_json
  end
  
end
