class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :tax_id
      t.decimal :amount, null: false, precision: 8, scale: 2
      t.boolean :completed, default: false
      t.string :stripe_transfer_id
      t.string  :bank_token
      t.string :bank_last4
      t.datetime :completed_at
      t.timestamps
    end
  end
end
