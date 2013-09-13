class Role < ActiveRecord::Base
  attr_accessible :user_id, :tax_id, :kind, :user_name

  belongs_to :user
  belongs_to :tax

  # Kinds
  MANAGER   = 1
  FUNDER    = 2
  TRUSTEE  = 3

  validates_uniqueness_of :user_id, :scope => [:tax_id, :kind]
  validate :user_is_not_manager_and_trustee

  scope :admin, where('kind IN (?)', [Role::MANAGER, Role::TRUSTEE])

  def user_name
    true
  end

  def user_is_not_manager_and_trustee
    if kind == Role::MANAGER || kind == Role::TRUSTEE
      if user.roles.admin.where('tax_id = ? AND id != ?', tax_id, id || 0).any?
        errors.add(:user_id, " cannot be both a trustee and manager")
      end
    end
  end

end