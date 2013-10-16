class AddStripeToken < ActiveRecord::Migration
  def up
    add_column :pledges, :stripe_token, :string
    add_column :taxes, :bank_token, :string
    add_column :taxes, :recipient_id, :string
  end

  def down
    remove_column :pledges, :stripe_token
    remove_column :taxes, :bank_token
    remove_column :taxes, :recipient_id
  end
end
