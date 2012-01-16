class Message < ActiveRecord::Base
  belongs_to :tax
  belongs_to :user
  
  after_save :send_mail
  
  DRAFT     = 0
  PUBLISHED = 1
  TRASH     = 2
  
  def recipients
    tax.pledgers
  end

  scope :draft, where(:status => DRAFT)
  scope :published, where(:status => PUBLISHED)
    
  def draft?
    status == DRAFT
  end
  def published?
    status == PUBLISHED
  end
  
  def effective_title
    self.title.blank? ? "To #{self.tax.name}, #{self.created_at.strftime('%b %d, %Y')}" : self.title
  end
  
  protected
  
  def send_mail
    if self.status_changed? and self.published?
      Mailer.tax_message(self).deliver
    end
  end
  
end
