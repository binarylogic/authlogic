class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.string :login, :null => false
      t.string :crypted_password
      t.string :password_salt
      t.string :remember_token
      t.string :first_name
      t.string :last_name
      t.integer :login_count, :null => false, :default => 0
      t.datetime :last_request_at
      t.integer :profile_views, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :users
  end
end
