class Transaction < ActiveRecord::Base
  attr_accessible :user_id, :parent_id, :parent_type, :amount, :method
  belongs_to :user
  belongs_to :parent, polymorphic: true

  validates_presence_of :user, :parent

  def tax
    if self.parent_type == "Pledge"
      self.parent.tax
    else
      self.parent
    end
  end

end
