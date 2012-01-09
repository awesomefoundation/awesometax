class Mailer < ActionMailer::Base
  @@from_address = "AwesomeTax <team@lovetax.us>"
  
  #LL_NEWS       = 1
  #LL_NOTIFY     = 2
  #TAX_NOTIFY    = 3
  #TAX_COMMENTS  = 4
  
  def welcome(user)
    recipients    user.email
    from          @@from_address
    subject       "[AwesomeTax] Welcome to AwesomeTax!"
    sent_on       Time.now
    body          :user => user
    content_type  'text/html'
  end

  def payment(user, pledges)
    recipients    user.email
    from          @@from_address
    subject       "[AwesomeTax] It's that time of the month"
    sent_on       Time.now
    body          :user => user, :pledges => pledges
    content_type  'text/html'
  end

  def new_pledge(owner, pledge)
    recipients    owner.email
    from          @@from_address
    subject       "[AwesomeTax] You have a new taxpayer!"
    sent_on       Time.now
    body          :owner => owner, :pledge => pledge
    content_type  'text/html'
  end
  
  def comment(owner, comment)
    recipients    owner.email
    from          @@from_address
    subject       "[AwesomeTax] #{comment.user.name} commented on your tax"
    sent_on       Time.now
    body          :owner => owner, :comment => comment
    content_type  'text/html'
  end
  
  def admin_notification(subj, message)
    recipients    ['larry@makeloveland.com', 'jerry@makeloveland.com', 'mary@makeloveland.com']
    from          @@from_address
    subject       "[AwesomeTax] #{subj}"
    sent_on       Time.now
    body          :message => message
    content_type  'text/html'
  end

end
