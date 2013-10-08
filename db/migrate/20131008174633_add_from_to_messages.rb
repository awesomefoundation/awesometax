class AddFromToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :from, :string, default: "contact@awesomefoundation.org"
  end
end
