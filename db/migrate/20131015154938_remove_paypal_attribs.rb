class RemovePaypalAttribs < ActiveRecord::Migration
  def up
    remove_column :pledges, :preapproval_key
    remove_column :taxes, :paypal_email
  end

  def down
    add_column :pledges, :preapproval_key, :string
    add_column :taxes, :paypal_email, :string
  end
end
