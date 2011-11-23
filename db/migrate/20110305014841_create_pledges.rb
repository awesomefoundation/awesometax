class CreatePledges < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|
      t.integer :user_id, :null => false
      t.integer :tax_id
      t.integer :portfolio_id
      t.datetime :starts, :null => false
      t.datetime :ends
      t.integer :status, :null => false
      t.decimal :amount, :null => false, :precision => 8, :scale => 2
      t.decimal :cumulative, :null => false, :default => 0, :precision => 8, :scale => 2
      t.string :preapproval_key

      t.timestamps
    end
  end

  def self.down
    drop_table :pledges
  end
end
