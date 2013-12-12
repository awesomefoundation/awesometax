class RemoveKindFromTransactions < ActiveRecord::Migration
  def up
    remove_column :transactions, :kind
  end

  def down
    add_column :transactions, :kind, :integer
  end
end
