class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :title
      t.date :started
      t.date :ended
      t.boolean :confirmed
      t.integer :user_id
      t.integer :startup_id
      t.timestamps
    end

    add_index :roles, :user_id
    add_index :roles, :startup_id
  end
end
