class Tax < ActiveRecord::Base
  # Status
  INACTIVE = 0
  ACTIVE   = 1
  ENDED    = 2
  
  belongs_to :owner, :class_name => 'User'
  has_many :pledges
  has_many :pledgers, :through => :pledges, :source => :user
  has_many :comments
  
  scope:active, where(:status => Tax::ACTIVE)
  
  attr_accessible :name, :description, :paypal_email, :video_type, :video_id
  validates_length_of :name, :minimum => 8
  validates_length_of :name, :maximum => 40
  validates_length_of :description, :minimum => 20
  validates_presence_of :owner_id

  def monthly_income
    pledges.active.inject(0) { |sum,p| sum + p.amount }
  end
  
  def total_income
    pledges.active.inject(0) { |sum,p| sum + p.cumulative }
  end
  
  def unique_supporters
    pledges.active.collect { |p| p.user }.uniq
  end
  
  def stop
    update_attribute(:status, Tax::ENDED)
    pledges.each { |p| p.stop }
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
    
end
