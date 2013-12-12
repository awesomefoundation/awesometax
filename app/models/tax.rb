class Tax < ActiveRecord::Base
  require 'mogrify'
  include Mogrify

  # Status
  INACTIVE = 0
  ACTIVE   = 1
  ENDED    = 2

  belongs_to :owner, :class_name => 'User' # Deprecated mostly, just marks who started it (ie entered the banking info)
  has_many :pledges
  has_many :active_pledges, :class_name => 'Pledge', :conditions => {:status => Pledge::ACTIVE}
  has_many :pledgers, :through => :active_pledges, :source => :user, :uniq => true
  has_many :comments
  has_many :transactions, :through => :pledges
  has_many :transfers
  has_many :messages

  has_many :roles, :dependent => :destroy
  has_many :funder_roles,  :class_name => 'Role', :conditions => { :kind => Role::FUNDER }, :uniq => true
  has_many :manager_roles, :class_name => 'Role', :conditions => { :kind => Role::MANAGER }, :uniq => true
  has_many :trustee_roles, :class_name => 'Role', :conditions => { :kind => Role::TRUSTEE }, :uniq => true

  has_many :funders,  :class_name => 'User', :through => :funder_roles,  :source => :user, :uniq => true
  has_many :managers, :class_name => 'User', :through => :manager_roles, :source => :user, :uniq => true
  has_many :trustees, :class_name => 'User', :through => :trustee_roles, :source => :user, :uniq => true

  scope :active, where(:status => Tax::ACTIVE)

  attr_accessible :name, :description, :video_type, :video_id, :goal, :bank_token, :recipient_id
  validates_length_of :name, :minimum => 5
  validates_length_of :name, :maximum => 40
  validates_length_of :description, :minimum => 20
  validates :goal, :numericality => { :greater_than_or_equal_to => AppConfig.minimum_goal }
  #validates_presence_of :owner_id
  validate :create_stripe_recipient, on: :create

  before_save :update_slug
  after_create :notify_admins

  def self.find_tax(tax_id)
    tax = Tax.find_by_slug(tax_id.to_s)
    tax || Tax.find(tax_id.to_i)
  end

  def meets_goal
    goal.nil? or monthly_income > goal
  end

  def collect_pledges
    total = 0

    puts "Running #{self.pledges.active.count.to_s} transactions for #{self.name}"
    self.pledges.active.each do |p|
      puts "  Considering pledge #{p.id}..."
      next if Rails.env.production? && !p.transactions.empty? and Date.today.month == Transaction.last.created_at.month  # Safety net to not run twice in the same month
      if p.collect
        total += p.recipient_cut
        puts "new total #{total}"
        puts "  Successfully collected pledge #{p.id} for $#{p.amount}"
      else
        puts "  Problem collecting pledge #{p.id}"
      end
    end

    transfer = Transfer.create({
      :tax_id => self.id,
      :amount => total - 0.25,
      :completed => false
    })

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
    transfers.sum(:amount)
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

  def create_stripe_recipient
    begin
      recipient = Stripe::Recipient.create(
        :name => self.owner.name,
        :type => "individual",
        :email => self.owner.email,
        :bank_account => bank_token
      )
    rescue => e
      logger.info "error: #{e.message}"
      errors[:base] << "#{e.message}"
      return
    end

    self.recipient_id = recipient.id

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
