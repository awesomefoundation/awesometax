class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax
  
  # Kinds
  MANAGER   = 1
  FUNDER    = 2
  FAVORITE  = 3
end
