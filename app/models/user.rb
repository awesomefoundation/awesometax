class User < ActiveRecord::Base
  require 'mogrify'

  devise :database_authenticatable, :token_authenticatable, :omniauthable, :confirmable, :recoverable,
    :registerable, :rememberable, :trackable, :validatable, :encryptable

  EMAIL_SETTINGS = {payment: true, new_pledge: true, comment: true, tax_message: true}

  has_settings do |s|
    s.key :email, :defaults => EMAIL_SETTINGS
  end
    # Use mailer method names, eg user.settings['email.new_pledge'] is true/false. defaults in config/initializers/settings.rb
  # More at https://github.com/ledermann/rails-settings

  include Gravtastic
  has_gravatar :rating => 'PG', :default => 'identicon'
  has_attached_file :picture, :styles => { :thumb => ["80x80#", :jpg], :mini => ["32x32#", :jpg] },
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"

  # status
  NORMAL   = 0
  ADMIN    = 1
  VERIFIED = 2
  DISABLED = 3


  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :status
  attr_accessible :settings, :url, :bio, :twitter, :picture
  validates_length_of :bio, :maximum => 140
  validates :email, :uniqueness => true
  validates :name, :presence => true,
    :format => { :with => /^[a-zA-Z]+\s[a-zA-Z]+$/, :message => " should contain first and last name" }
  before_validation :strip_whitespace, :only => [:name, :email]

  has_many :pledges
  has_many :transactions
  has_many :sent_messages, :class_name => 'Message'

  has_many :roles, :dependent => :destroy
  has_many :funder_roles,  :class_name => 'Role', :conditions => { :kind => Role::FUNDER }, :uniq => true
  has_many :manager_roles, :class_name => 'Role', :conditions => { :kind => Role::MANAGER }, :uniq => true
  has_many :trustee_roles, :class_name => 'Role', :conditions => { :kind => Role::TRUSTEE }, :uniq => true

  has_many :funded_taxes,  :class_name => 'Tax',  :through => :funder_roles,  :source => :tax, :uniq => true
  has_many :managed_taxes, :class_name => 'Tax',  :through => :manager_roles, :source => :tax, :uniq => true
  has_many :trusted_taxes, :class_name => 'Tax',  :through => :trustee_roles, :source => :tax, :uniq => true


  scope :admins,   where(:status => ADMIN)

  after_create :notify_created
  before_picture_post_process :modify


  def strip_whitespace
    self.name = self.name.strip
    self.email = self.email.strip
  end

  def admin?
    status == ADMIN
  end

  def status_s
    { NORMAL    => 'Normal',
      ADMIN     => 'Admin',
      VERIFIED  => 'Verified',
      DISABLED  => 'Disabled' }[status]
  end

  def labels
    list = []
    list << 'Administrator' if self.admin?
    list << 'Supporter' if self.pledges.active.exists?
    return list
  end

  def picture_url(opts = {})
    self.picture.exists? ? picture.url(opts[:size] == 32 ? :mini : :thumb) : gravatar_url(opts)
  end


  def messages
    tax_ids = pledges.approved.collect { |p| p.tax_id }.uniq
    Message.where(:tax_id => tax_ids).order('id desc')
  end

  # s is a (potentially incomplete) hash of the email preferences from a form (so => "1"). For missing ones, set them to false
  def update_settings(s)
    s = {} if s.nil?
    User::EMAIL_SETTINGS.each do |k,v|
      self.settings(:email).update_attributes! k => s.has_key?(k) && s[k].to_i == 1
    end
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


  def modify
    logger.info "Modify gets: #{picture_file_name}"
    # self.picture.instance_write(:file_name, transliterate_file_name(self.picture_file_name))
    # logger.info "and ends with: #{picture_file_name}"
  end

end
