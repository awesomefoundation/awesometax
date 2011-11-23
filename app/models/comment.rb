class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax
  
  validates_presence_of :user_id
  validates_presence_of :tax_id
  validates_length_of :body, :minimum => 1
  
  attr_accessible :body, :user_id, :tax_id, :user, :tax
  
  def editable_by(u)
    return false if u.nil?   # not logged in
    user == u or u.admin? or u == tax.owner
  end
end
