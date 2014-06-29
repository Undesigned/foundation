class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :title
      t.date :started
      t.date :ended
      t.integer :user_id
      t.integer :startup_id
      t.timestamps
    end
  end
end
