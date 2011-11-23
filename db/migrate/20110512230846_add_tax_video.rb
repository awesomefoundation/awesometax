class AddTaxVideo < ActiveRecord::Migration
  def self.up
    add_column :taxes, :video_type, :string
    add_column :taxes, :video_id, :string
  end

  def self.down
    remove_column :taxes, :video_type
    remove_column :taxes, :video_id
  end
end
