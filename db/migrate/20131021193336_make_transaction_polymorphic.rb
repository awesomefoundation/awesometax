class MakeTransactionPolymorphic < ActiveRecord::Migration
  def up
    rename_column :transactions, :pledge_id, :parent_id
    add_column :transactions, :parent_type, :string, default: "pledge"
  end

  def down
    rename_column :transactions, :parent_id, :pledge_id
    remove_column :transactions, :parent_type
  end
end
