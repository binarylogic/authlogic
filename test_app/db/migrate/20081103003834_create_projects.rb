class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.timestamps
      t.string :name
    end
    
    create_table :projects_users, :id => false, :force => true do |t|
      t.integer :project_id, :null => false
      t.integer :user_id,  :null => false
    end
  end

  def self.down
    drop_table :projects
    drop_table :projects_users
  end
end
