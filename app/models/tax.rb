class Tax < ActiveRecord::Base
  require 'mogrify'
  include Mogrify

  # Status
  INACTIVE = 0
  ACTIVE   = 1
  ENDED    = 2

  belongs_to :owner, :class_name => 'User' # Deprecated mostly, just marks who started it (ie entered the paypal recipient info)
  has_many :pledges
  has_many :active_pledges, :class_name => 'Pledge', :conditions => {:status => Pledge::ACTIVE}
  has_many :pledgers, :through => :active_pledges, :source => :user, :uniq => true
  has_many :comments
  has_many :transactions, :through => :pledges
  has_many :messages

  has_many :roles, :dependent => :destroy
  has_many :funder_roles,  :class_name => 'Role', :conditions => { :kind => Role::FUNDER }, :uniq => true
  has_many :manager_roles, :class_name => 'Role', :conditions => { :kind => Role::MANAGER }, :uniq => true
  has_many :trustee_roles, :class_name => 'Role', :conditions => { :kind => Role::TRUSTEE }, :uniq => true

  has_many :funders,  :class_name => 'User', :through => :funder_roles,  :source => :user, :uniq => true
  has_many :managers, :class_name => 'User', :through => :manager_roles, :source => :user, :uniq => true
  has_many :trustees, :class_name => 'User', :through => :trustee_roles, :source => :user, :uniq => true

  scope :active, where(:status => Tax::ACTIVE)

  attr_accessible :name, :description, :paypal_email, :video_type, :video_id, :goal
  validates_length_of :name, :minimum => 5
  validates_length_of :name, :maximum => 40
  validates_length_of :description, :minimum => 20
  validates :goal, :numericality => { :greater_than_or_equal_to => AppConfig.minimum_goal }
  #validates_presence_of :owner_id

  before_save :update_slug
  after_create :notify_admins

  def meets_goal
    goal.nil? or monthly_income > goal
  end

  #TODO: Could this be faster with an activerecord relation?
  def supervisors
    (self.managers + self.trustees).uniq
  end

  def monthly_income
    pledges.active.sum(:amount)
  end

  def percent_funded
    return 100 if goal.to_i == 0
    return (100.0 * monthly_income / goal).to_i
  end

  def total_income
    transactions.received.sum(:amount)
  end

  # aka "funders" assoc
  def unique_supporters
    pledges.active.collect { |p| p.user }.uniq
  end

  def stop
    update_attribute(:status, Tax::ENDED)
    pledges.each { |p| p.stop }
    funders.clear
  end

  def active?
    status == ACTIVE
  end

  @@status_strings = {
    INACTIVE  => "Inactive",
    ACTIVE    => "Active",
    ENDED     => "Terminated"
  }

  def status_string
    @@status_strings[status]
  end

  def update_slug
    s = self.name.clone
    self.slug = transliterate(s)
  end

  def notify_admins
    begin
      Mailer.admin_notification("#{self.managers.first.name} created a tax: #{self.name}",
        h(tax_url(:id => self.id, :only_path => false))).deliver
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
    end
  end

end
