class FreshenTaxes < ActiveRecord::Migration
  def self.up
    remove_column :taxes, :video_type
    remove_column :taxes, :video_id
    remove_column :taxes, :url
    remove_column :taxes, :category_id
    add_column :taxes, :goal, :integer
    remove_column :pledges, :portfolio_id
  end

  def self.down
    add_column :taxes, :video_type, :string
    add_column :taxes, :video_id, :string
    add_column :taxes, :url, :string
    add_column :taxes, :category_id, :integer
    remove_column :taxes, :goal
    add_column :pledges, :portfolio_id, :integer
  end
end
