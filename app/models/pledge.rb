class Pledge < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :tax
  has_many   :transactions

  INACTIVE  = 0 # has not been confirmed yet
  ACTIVE    = 1
  PAUSED    = 3 # you can do this thru account page
  FINISHED  = 4 # voluntarily
  FAILED    = 5 # a problem. failed, cancelled, expired...

  scope :active,   where(:status => ACTIVE)
  scope :approved, where('status > 0')
  scope :inactive, where(:stauts => INACTIVE)

  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than => 10000
  validates_presence_of :tax
  # validates :user_id, :uniqueness => {:scope => :tax_id, :message => "already funds this tax"}
  validates :amount, :numericality => { :greater_than_or_equal_to => 5, :message => " must be at least $5" }
  validate :tax_is_active

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
  def recipient_cut
    amount - stripe_cut
  end
  def stripe_cut
    #from https://stripe.com/us/help/pricing
    #charge cut + transfer cut
    (amount*0.029) + 0.55
  end

  def start
    update_attribute(:status, Pledge::ACTIVE)
  end
  def pause
    update_attribute(:status, Pledge::PAUSED)
  end
  def stop
    customer = Stripe::Customer.retrieve(self.stripe_token)
    response = customer.delete

    update_attribute(:status, Pledge::FINISHED)
  end

  def tax_is_active
    self.tax.status == Tax::ACTIVE
  end


  #------------

  def collect
    logger.info "collect_pledge: #{self.inspect}"

    begin
      Stripe::Charge.create(
        :amount => (amount*100).to_i, # amount in cents, again
        :currency => "usd",
        :customer => stripe_token,
        :description => "#{tax.name}"
      )
    rescue => e
      logger.info "error: #{e.message}"
      errors[:base] << "#{e.message}"
      return
    end

    charge = Transaction.create({
      :user_id => user_id,
      :pledge_id => id,
      :amount => amount,
      :kind => Transaction::SENT
    })

    if charge.save

      begin
        Stripe::Transfer.create(
          #i know this is weird, but stripe adds on the extra 25 cents
          :amount => (100*amount).to_i - 25, # amount in cents
          :currency => "usd",
          :recipient => tax.recipient_id,
          :statement_descriptor => "#{tax.name}"
        )
      rescue => e
        logger.info "error: #{e.message}"
        errors[:base] << "#{e.message}"
        return
      end

      transfer = Transaction.create({
        :user_id => tax.owner_id,
        :pledge_id => id,
        :amount => recipient_cut,
        :kind => Transaction::RECEIVED
      })
    else
      errors[:base] << charge.errors.full_messages.join(", ")
      return
    end

  end


  # This generally runs as a rake task, "rake taxes:collect"
  def self.collect_all
    if Transaction.count != 0 && Date.today.month == Transaction.last.created_at.month
      puts "There has already been a collection recently. No can do. This is a safeguard that's very easy to override if you mean it."
      return
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
      next if !p.transactions.empty? and Date.today.month == Transaction.last.created_at.month  # Safety net to not run twice in the same month
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
