class CreateTaxes < ActiveRecord::Migration
  def self.up
    create_table :taxes do |t|
      t.string :name, :null => false
      t.text :description, :null => false
      t.integer :owner_id, :null => false
      t.string :url
      t.integer :category_id
      t.string :paypal_email

      t.timestamps
    end
  end

  def self.down
    drop_table :taxes
  end
end
