class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax

  validates_presence_of :user_id, :tax_id
  validates_length_of :body, :minimum => 1
  after_create :notify_managers

  attr_accessible :body, :user_id, :tax_id, :user, :tax

  def editable_by(u)
    return false if u.nil?   # not logged in
    self.user == u or u.admin? or tax.managers.include?(u)
  end

  def notify_managers
    begin
      Mailer.comment(self.tax.managers.select { |u| u.settings(:email).comment }, self).deliver
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
    end
  end

end
