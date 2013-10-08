class Mailer < ActionMailer::Base
  default :from => "contact@awesomefoundation.org"
  @@admins = [ 'larry@makeloveland.com', 'jerry@makeloveland.com', 'mary@makeloveland.com' ]


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

  def new_pledge(managers, pledge)
    @pledge = pledge
    category 'new_pledge'
    mail(:to => managers.collect { |u| u.email }, :subject => tag("You have a new taxpayer on #{pledge.tax.name}"))
  end

  def comment(recipients, comment)
    @comment = comment
    category 'comment'
    mail(:to => recipients.collect { |u| u.email }, :subject => tag("#{comment.user.name} commented on your tax, #{comment.tax.name}"))
  end

  def admin_notification(subj, message)
    @message = message
    category 'admin_notification'
    mail(:to => @@admins, :subject => tag(subj))
  end

  def tax_message(message)
    @message = message
    category 'message'
    mail(:to => message.recipients.collect { |u| u.email }, :from => message.from, :subject => message.effective_title)
  end

  private
  def tag(str)
    "[AwesomeTax#{Rails.env == 'production' ? '' : (' ' + Rails.env)}] #{str}"
  end
  def category(c)
    headers({ 'X-SMTPAPI' => { 'category' => "tax_#{Rails.env}_#{c}" }.to_json })
  end

end
