class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :token_authenticatable, :omniauthable, :confirmable, :recoverable,
    :registerable, :rememberable, :trackable, :validatable, :encryptable

  # status
  NORMAL   = 0
  ADMIN    = 1
  VERIFIED = 2
  TRUSTEE  = 3
  DISABLED = 4

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :status
  
  has_many :pledges
  has_many :transactions
  has_many :sent_messages, :class_name => 'Message'

  has_many :roles, :dependent => :destroy
  has_many :funder_roles,  :class_name => 'Role', :conditions => { :kind => Role::FUNDER }, :uniq => true
  has_many :manager_roles, :class_name => 'Role', :conditions => { :kind => Role::MANAGER }, :uniq => true
  has_many :funded_taxes,  :class_name => 'Tax',  :through => :funder_roles,  :source => :tax, :uniq => true
  has_many :managed_taxes, :class_name => 'Tax',  :through => :manager_roles, :source => :tax, :uniq => true
  
  scope :admins,   where(:status => ADMIN)
  scope :trustees, where(:status => TRUSTEE)

  def admin?
    status == ADMIN
  end
  def trustee?
    status == TRUSTEE
  end
  
  def status_s
    { NORMAL    => 'Normal',
      ADMIN     => 'Admin',
      VERIFIED  => 'Verified',
      TRUSTEE   => 'Trustee',
      DISABLED  => 'Disabled' }[status]
  end
  
  def messages
    tax_ids = pledges.approved.collect { |p| p.tax_id }.uniq
    Message.where(:tax_id => tax_ids).order('id desc')
  end
  

end
