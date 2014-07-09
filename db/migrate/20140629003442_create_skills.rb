class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name

      t.timestamps
    end
    add_index :skills, :name, unique: true

    create_table :skills_users, :id => false do |t|
      t.references :skill
      t.references :user
    end
    add_index :skills_users, [:skill_id, :user_id], unique: true
    add_index :skills_users, :user_id
  end
end
