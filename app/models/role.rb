class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax
  
  
  MANAGER = 1
  FUNDER  = 2
  
end
