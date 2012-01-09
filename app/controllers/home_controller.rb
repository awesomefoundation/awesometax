class HomeController < ApplicationController
  
  include ActionView::Helpers::NumberHelper
  
  def index
    @featured = Tax.all(:order => 'id desc', :limit => 6, :conditions => {:status => Tax::ACTIVE})
    @nc = next_collection_time
  end
  
  def mock
  end
  
  def widget
    @tax = Tax.find(params[:id])
    @json = {
      :id           => @tax.id,
      :name         => @tax.name,
      :description  => @tax.description,
      :supporters   => @tax.unique_supporters.count,
      :monthly      => number_to_currency(@tax.monthly_income),
      :created      => @tax.created_at.strftime('%m-%d-%y')
    }.to_json
  end
  
end
