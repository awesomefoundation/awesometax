class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :pledge_id, :amount, :kind, :method
  belongs_to :user
  belongs_to :pledge
  
  validates_presence_of :user, :pledge
  
  # Kinds
  SENT = 1
  RECEIVED = 2

  scope :sent, where(:kind => SENT)
  scope :received, where(:kind => RECEIVED)
end
