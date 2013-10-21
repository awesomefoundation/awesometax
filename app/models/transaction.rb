class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :parent_id, :parent_type, :amount, :kind, :method
  belongs_to :user
  belongs_to :parent, polymorphic: true

  validates_presence_of :user, :parent

  # Kinds
  SENT = 1
  RECEIVED = 2

  scope :sent, where(:kind => SENT)
  scope :received, where(:kind => RECEIVED)
end
