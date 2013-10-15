class AddStripeToken < ActiveRecord::Migration
  def up
    add_column :users, :stripe_token, :string
    add_column :taxes, :bank_token, :string
  end

  def down
    remove_column :users, :stripe_token
    remove_column :taxes, :bank_token
  end
end
