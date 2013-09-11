class DeviseCreateUsers < ActiveRecord::Migration
  #update migration for Devise 2.0
  #see https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style
  def self.up
    create_table(:users) do |t|
      t.string    :name,              :null => false
      t.integer   :status

      ## Database authenticatable
      t.string :email,              :null => false
      t.string :encrypted_password, :null => false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

       ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Encryptable
      t.string :password_salt

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      # Token authenticatable
      t.string :authentication_token

      # t.string    :name,              :null => false
      # t.string    :email,             :null => false
      # t.integer   :status

      # t.database_authenticatable :null => false
      # t.recoverable
      # t.rememberable
      # t.trackable

      # t.encryptable
      # t.confirmable
      # t.token_authenticatable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    add_index :users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end