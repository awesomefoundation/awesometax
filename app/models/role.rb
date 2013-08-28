class Role < ActiveRecord::Base
  attr_accessible :user_id, :tax_id, :kind, :user_name

  belongs_to :user
  belongs_to :tax

  # Kinds
  MANAGER   = 1
  FUNDER    = 2
  TRUSTEE  = 3

  validates :user_id, uniqueness: { :scope => [:tax_id, :kind]}
  validate :user_is_not_manager_and_trustee

  def user_name
    true
  end

  def user_is_not_manager_and_trustee
    if User.find(self.user_id).managed_taxes.include?(self.tax)
      errors.add(:user_id, " is already a manager")
    end
  end

end