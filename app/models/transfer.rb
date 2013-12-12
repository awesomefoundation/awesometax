class Transfer < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tax

  scope :pending, where(:completed => false)
  scope :completed, where(:completed => true)


  def complete_transfer
    # don't run if we have already made this transfer or if it is less than 7 days old
    return if self.completed == true || self.created_at > (Time.zone.now - 7.days)

    begin
      puts "Going to transfer $#{amount} to #{tax.name}"
      stripe_transfer = Stripe::Transfer.create(
        #i know this is weird, but stripe adds on the extra 25 cents
        :amount => (100*amount).to_i, # amount in cents
        :currency => "usd",
        :recipient => tax.recipient_id,
        :statement_descriptor => "#{tax.name}"
      )

      self.completed = true
      self.completed_at = Time.zone.now
      self.stripe_transfer_id = stripe_transfer.id
      self.bank_last4 = stripe_transfer.account.last4
      self.bank_token = tax.bank_token
      self.save

    rescue => e
      logger.info "error: #{e.message}"
      errors[:base] << "#{e.message}"
      return
    end
  end

end
