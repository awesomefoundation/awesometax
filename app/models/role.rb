class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax

  # Kinds
  MANAGER   = 1
  FUNDER    = 2
  FAVORITE  = 3

  validates :user_id, uniqueness: { :scope => [:tax_id, :kind]}
end