class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :tax_id, :null => false
      t.integer :user_id, :null => false
      t.integer :status, :null => false, :default => Message::DRAFT
      t.string :title
      t.text :body, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
