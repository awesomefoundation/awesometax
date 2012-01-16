class Message < ActiveRecord::Base
  belongs_to :tax
  belongs_to :user
  
  def recipients
    tax.pledgers
  end
end
