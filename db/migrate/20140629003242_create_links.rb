class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :title
      t.string :href
      t.string :owner_type
      t.integer :owner_id
      t.timestamps
    end

    add_index :links, [:owner_id, :owner_type, :title]
  end
end
