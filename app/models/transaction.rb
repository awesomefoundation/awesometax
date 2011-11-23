class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :pledge_id, :amount, :kind, :method
  belongs_to :user
  belongs_to :pledge

  # kinds
  SENT = 1
  RECEIVED = 2
end
