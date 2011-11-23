class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :name,              :null => false
      t.string    :email,             :null => false
      t.integer   :facebook_uid,      :limit => 8
      t.integer   :status,            :null => false
      t.string    :crypted_password,  :null => false
      t.string    :password_salt,     :null => false
      t.string    :persistence_token, :null => false
      t.string    :single_access_token,:null => false
      t.integer   :login_count,       :null => false, :default => 0
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
