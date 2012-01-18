class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :token_authenticatable, :omniauthable, :confirmable, :recoverable,
    :registerable, :rememberable, :trackable, :validatable, :encryptable
    
  has_settings
  # Use mailer method names, eg user.settings['email.new_pledge'] is true/false. defaults in config/initializers/settings.rb
  # More at https://github.com/ledermann/rails-settings
  
  include Gravtastic
  has_gravatar :rating => 'PG', :default => 'identicon'
    
  # status
  NORMAL   = 0
  ADMIN    = 1
  VERIFIED = 2
  TRUSTEE  = 3
  DISABLED = 4

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :status, :settings, :url, :bio, :twitter
  validates_length_of :bio, :maximum => 140
  
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
  
  after_create :notify_created

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
  
  def labels
    list = []
    list << 'Administrator' if self.admin?
    list << 'Trustee' if self.trustee?
    list << 'Supporter' if self.pledges.active.exists?
    return list
  end
  
  def messages
    tax_ids = pledges.approved.collect { |p| p.tax_id }.uniq
    Message.where(:tax_id => tax_ids).order('id desc')
  end
  
  # s is a (potentially incomplete) hash of the email preferences from a form (so => "1"). For missing ones, set them to false
  def update_settings(s)
    s.each { |k,v| self.settings[k] = (v.to_i == 1) }
    Settings.defaults.each { |k,v| self.settings[k] = false if s[k].to_i == 0 }
  end
  
  protected
  
  def notify_created
    begin
      Mailer.admin_notification("New user #{@user.name}", "Just letting you know someone joined!").deliver
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
    end
  end

end
