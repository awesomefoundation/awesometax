class HomeController < ApplicationController
  
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  
  def index
    @taxes = Tax.active.order('id asc')
    @columns = [ [], [] ]
    @taxes.each_with_index { |t,i| @columns[i & 1] << t }
  end
  
  def mock
    @tax = Tax.find_by_slug 'new-orleans'
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
