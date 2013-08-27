class Role < ActiveRecord::Base
  attr_accessible :user_id, :tax_id, :kind, :user_name

  belongs_to :user
  belongs_to :tax

  # Kinds
  MANAGER   = 1
  FUNDER    = 2
  FAVORITE  = 3

  validates :user_id, uniqueness: { :scope => [:tax_id, :kind]}

  def user_name
    true
  end

end