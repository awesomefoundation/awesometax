class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :user_id, :null => false
      t.integer :pledge_id, :null => false
      t.decimal :amount, :null => false, :precision => 8, :scale => 2
      t.integer :kind, :null => false
      t.integer :method

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
