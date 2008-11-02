class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.timestamps
      t.string :name
    end
  end

  def self.down
    drop_table :accounts
  end
end
