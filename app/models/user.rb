class User < ActiveRecord::Base
  devise :database_authenticatable, :token_authenticatable, :omniauthable, :confirmable, :recoverable,
    :registerable, :rememberable, :trackable, :validatable, :encryptable

  # status
  NORMAL   = 0
  ADMIN    = 1
  VERIFIED = 2
  BOARD    = 3
  DISABLED = 4

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :status
  
  has_many :pledges
  #has_many :taxes, :class_name => 'Tax', :foreign_key => 'owner_id'
  has_many :roles
  has_many :taxes, :through => :roles
  has_many :transactions
  
  scope :admins, where(:status => ADMIN)
  scope :board_members, where(:status => BOARD)

  def admin?
    status == ADMIN
  end
  
  def board?
    status == BOARD
  end

end
