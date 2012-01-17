class ProfileDetails < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :url
      t.string :bio
      t.string :twitter
    end
  end

  def self.down
    change_table :users do |t|
      remove_column :users, :url
      remove_column :users, :bio
      remove_column :users, :twitter
    end
  end
end
