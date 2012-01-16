class Message < ActiveRecord::Base
  belongs_to :tax
  belongs_to :user
  
  DRAFT     = 0
  PUBLISHED = 1
  TRASH = 2
  
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
  
end
