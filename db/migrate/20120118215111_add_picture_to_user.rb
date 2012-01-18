class AddPictureToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      # t.has_attached_file :picture
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
    end
  end

  def self.down
    #drop_attached_file :users, :picture
    remove_column :users, :picture_file_name
    remove_column :users, :picture_content_type
    remove_column :users, :picture_file_size
  end
end

