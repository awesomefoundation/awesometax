class AddSlugs < ActiveRecord::Migration
  def self.up
    add_column :taxes, :slug, :string, :unique => true
    Tax.find_each do |t|
      t.update_attribute(:slug, Tax.make_slug(t.name))
    end
  end

  def self.down
    remove_column :taxes, :slug
  end
end
