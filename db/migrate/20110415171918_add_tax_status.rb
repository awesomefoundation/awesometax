class AddTaxStatus < ActiveRecord::Migration
  def self.up
    add_column :taxes, :status, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :taxes, :status
  end
end
