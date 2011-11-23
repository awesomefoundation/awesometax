class User < ActiveRecord::Base
  devise :database_authenticatable, :token_authenticatable, :omniauthable, :confirmable, :recoverable,
    :registerable, :rememberable, :trackable, :validatable, :encryptable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email_prefs, :status
  
  has_many :pledges
  has_many :active_pledges, :conditions => ['status = ?', Pledge::ACTIVE]
  has_many :taxes, :class_name => 'Tax', :foreign_key => 'owner_id'
  has_many :transactions
  
  # status
  NORMAL   = 0
  VERIFIED = 1
  ADMIN    = 2
  DISABLED = 3

  def admin?
    status == ADMIN
  end
  
  def wants_email?(kind)
    bit = 1 << (kind - 1)
    email_prefs.to_i & bit == bit
  end
  
  def set_email_pref(kind, value)
    logger.info "set_email(#{kind}, #{value}) before #{email_prefs}"
    bit = (1 << (kind.to_i - 1)).to_i
    logger.info "The bit is #{bit}"
    if value
      self.email_prefs = email_prefs.to_i | bit
    else
      self.email_prefs = email_prefs.to_i & ~bit
    end
    logger.info "set_email after #{self.email_prefs}"
    return email_prefs
  end

end
