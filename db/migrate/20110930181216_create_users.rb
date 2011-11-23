class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :uid
      t.string :name
      t.string :email
      t.string :status
      
      t.integer :inches
      t.integer :unplaced_inches
      t.string :username  #wtf?
      t.text :description
      t.text :plans
      t.text :rewards
      
      t.integer :sent_mail
      t.integer :email_pref
      
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
