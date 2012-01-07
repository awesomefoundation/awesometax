class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.integer :type, :null => false
      t.integer :user_id, :null => false
      t.integer :tax_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
