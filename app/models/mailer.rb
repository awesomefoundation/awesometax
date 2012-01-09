class Mailer < ActionMailer::Base
  default :from => "team@lovetax.us"
  @@admins = [ 'larry@makeloveland.com', 'jerry@makeloveland.com', 'mary@makeloveland.com' ]
  
  #LL_NEWS       = 1
  #LL_NOTIFY     = 2
  #TAX_NOTIFY    = 3
  #TAX_COMMENTS  = 4

  
  def welcome(user)
    @user = user
    category 'welcome'
    mail(:to => user.email, :subject => tag("Welcome to AwesomeTax!"))
  end

  def payment(user, pledges)
    @user = user
    @pledges = pledges
    category 'payment'
    mail(:to => user.email, :subject => tag("It's that time of the month"))
  end

  def new_pledge(owner, pledge)
    @owner = owner
    @pledge = pledge
    category 'new_pledge'
    mail(:to => owner.email, :subject => tag("You have a new taxpayer!"))
  end
  
  def comment(owner, comment)
    @owner = owner
    @comment = comment
    category 'comment'
    mail(:to => owner.email, :subject => tag("#{comment.user.name} commented on your tax"))
  end
  
  def admin_notification(subj, message)
    @message = message
    category 'admin_notification'
    mail(:to => @@admins, :subject => tag(subj))
  end

  private  
  def tag(str)
    "[AwesomeTax#{Rails.env == 'production' ? '' : (' ' + Rails.env)}] #{str}"
  end
  def category(c)
    headers({ 'X-SMTPAPI' => { 'category' => "tax_#{Rails.env}_#{c}" }.to_json })
  end

end
