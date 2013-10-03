class Pledge < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :tax
  has_many   :transactions

  INACTIVE  = 0 # has not been confirmed yet
  ACTIVE    = 1
  PAUSED    = 3 # you can do this thru paypal site ("suspended") or ours
  FINISHED  = 4 # voluntarily
  FAILED    = 5 # a problem. failed, cancelled, expired...

  scope :active,   where(:status => ACTIVE)
  scope :approved, where('status > 0')
  scope :inactive, where(:stauts => INACTIVE)

  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than => 10000
  validates_presence_of :tax
  validates :user_id, :uniqueness => {:scope => :tax_id, :message => "already funds this tax"}
  validates :amount, :numericality => { :greater_than_or_equal_to => 5, :message => " must be at least $5" }

  @@fuzzies = [
    [1,     'a little bit'],
    [2,     'a couple of bucks'],
    [8,     'a few bucks'],
    [19,    'a good amount'],
    [49,    'a generous amount'],
    [79,    'a really heartwarming amount'],
    [149,   'a wonderfully generous amount'],
    [249,   'an amazingly generous amount'],
    [399,   'an astonishing amount'],
    [699,   'a truly epic amount'],
    [10000, "so much you wouldn't believe us"],
  ]
  def fuzzy_amount
    @@fuzzies.each do |a,s|
      return s if amount <= a
    end
  end

  @@status_strings = {
    INACTIVE => 'inactive',
    ACTIVE   => 'active',
    PAUSED   => 'paused',
    FINISHED => 'ended',
    FAILED   => 'failed'
  }
  def status_string
    @@status_strings[status]
  end
  def active?
    status == Pledge::ACTIVE
  end
  def paused?
    status == Pledge::PAUSED
  end
  def stopped?
    [Pledge::FINISHED, Pledge::FAILED].include? status
  end

  # Fees and where the money goes
  def loveland_cut
    AppConfig.loveland_fee * amount
  end
  def recipient_cut
    amount - loveland_cut - paypal_cut
  end
  def paypal_cut
    0 # TODO: calculate it
  end

  def start
    update_attribute(:status, Pledge::ACTIVE)
  end
  def pause
    update_attribute(:status, Pledge::PAUSED)
  end
  def stop
    # Tell paypal it's over
    pay_request = PaypalAdaptive::Request.new
    data = {
      'requestEnvelope' => { 'errorLanguage' => 'en_US' },
      'preapprovalKey' => preapproval_key
    }
    pay_response = pay_request.cancel_preapproval(data)
    logger.info "pay_response: #{pay_response.inspect}"

    update_attribute(:status, Pledge::FINISHED)
  end


  def create_transactions
    Transaction.create({
      :user_id => user_id,
      :pledge_id => id,
      :amount => amount,
      :kind => Transaction::SENT
    })
    Transaction.create({
      :user_id => tax.owner_id,
      :pledge_id => id,
      :amount => recipient_cut,
      :kind => Transaction::RECEIVED
    })
    Transaction.create({
      :user_id => 0,  # 0 is a fake user, marks it as for the company
      :pledge_id => id,
      :amount => loveland_cut,
      :kind => Transaction::RECEIVED
    }) if AppConfig.loveland_fee > 0
  end


  #------------

  def collect
    logger.info "collect_pledge: #{self.inspect}"
    default_url_options[:host] = 'awesometax-test.herokuapp.com'
    pay_request = PaypalAdaptive::Request.new
    receiverList = [ { 'email' => tax.paypal_email, 'amount' => recipient_cut.to_s } ]
    receiverList << { 'email' => AppConfig.paypal_email, 'amount' => loveland_cut.to_s } if AppConfig.loveland_fee > 0
    data = {
      'actionType' => 'PAY',
      'requestEnvelope' => { 'errorLanguage' => 'en_US' },
      'currencyCode' => 'USD',
      'returnUrl' => url_for(:controller => 'pledges', :action => 'completed'),
      'cancelUrl' => url_for(:controller => 'pledges', :action => 'canceled'),
      'ipnNotificationUrl' => url_for(:controller => 'pledges', :action => 'notify'),
      'fees_payer' => 'EACHRECEIVER',
      'preapprovalKey' => preapproval_key,
      'receiverList' => { 'receiver' => receiverList },
    }

    pay_response = pay_request.pay(data)

    logger.info "pay_response: #{pay_response.inspect}"
    if pay_response.success?
      Pledge.transaction do
        update_attribute(:cumulative, cumulative + amount)
        create_transactions
      end
      logger.info "Success"
      return true
    else
      update_attribute(:status, Pledge::FAILED)
      logger.info "Failure"
      return false
    end
  end


  # This generally runs as a rake task, "rake taxes:collect"
  def self.collect_all
    if Rails.env.production?
      unless (Transaction.count == 0) or (Date.today - Transaction.last.created_at.to_date).to_i > 5
        puts "There has already been a collection recently. No can do. This is a safeguard that's very easy to override if you mean it."
        return
      end
    end

    done = 0
    pledges = Pledge.active.includes(:transactions, :tax) #.select { |p| p.tax.meets_goal }
    puts "Found #{pledges.size} active pledges"

    # Send emails
    users = pledges.collect { |p| p.user }.uniq.select { |u| u.settings(:email).payment }
    puts "Going to email #{users.size} users: #{users.collect { |u| u.email }.join(', ')}"
    users.each do |u|
      begin
        Mailer.payment(u, u.pledges.active).deliver
      rescue => e
        logger.info "Error sending mail to #{u.email}"
        logger.info e.inspect
        logger.info e.backtrace
      end
    end

    # Do the transactions
    puts "Running transactions:"
    pledges.each do |p|
      puts "  Considering pledge #{p.id}..."
      next if Rails.env.production? && !p.transactions.empty? and Time.zone.now - p.transactions.last.created_at < 1.day  # Safety net to not run twice in the same day
      if p.collect
        puts "  Successfully collected pledge #{p.id} for $#{p.amount}"
        done += 1
      else
        puts "  Problem collecting pledge #{p.id}"
      end
    end
    puts "Collected #{done} pledges successfully."
  end

end
